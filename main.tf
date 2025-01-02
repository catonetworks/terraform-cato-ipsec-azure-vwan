provider "azurerm" {
  features {}
  //TODO: Is it neccessary?
  subscription_id = var.azure_subscription_id
}

provider "cato" {
  baseurl    = var.cato_baseurl
  token      = var.cato_token
  account_id = var.cato_account_id
}

data "cato_entitylookup" "allocatedIps" {
  names = [var.cato_primary_public_ip]
  type = "allocatedIP"
}

locals {
  resource_group_name = regex("resourceGroups/(.*?)/providers", var.azure_vwan_hub_id)[0]
  hub_name                = regex("virtualHubs/(.*)", var.azure_vwan_hub_id)[0]
  allocated_ip_map = {
    for item in data.cato_entitylookup.allocatedIps.items :
    item.name => item.id  # Mapping name to ID
  }
  is_cato_primary_ip_exist = lookup(local.allocated_ip_map, tostring(var.cato_primary_public_ip), null)
}

resource "null_resource" "check_primary_ip" {
  provisioner "local-exec" {
    command = "exit 1"
    when    = local.is_cato_primary_ip_exist == null ? true : false
  }
  depends_on = [local.is_cato_primary_ip_exist]
}

data "azurerm_virtual_hub" "hub" {
  name = local.hub_name
  resource_group_name = local.resource_group_name
}

resource "random_password" "shared_key_primary" {
  length  = 32
  special = true
}

resource "azurerm_vpn_gateway" "cato_vpn_gateway" {
  name                = var.vpn_gateway_name
  location            = data.azurerm_virtual_hub.hub.location
  resource_group_name = local.resource_group_name
  virtual_hub_id      = var.azure_vwan_hub_id
}

resource "azurerm_vpn_site" "cato_vpn_site" {
  name                = var.vpn_site_name
  location            = data.azurerm_virtual_hub.hub.location
  resource_group_name = local.resource_group_name
  address_cidrs       = var.cato_site_address_cidrs
  virtual_wan_id      = data.azurerm_virtual_hub.hub.virtual_wan_id
  link {
    name       = var.vpn_site_primary_link_name
    ip_address = var.cato_primary_public_ip
    speed_in_mbps = var.connection_bandwidth
    bgp {
      asn = var.cato_asn
      peering_address = var.cato_peering_address
    }
  }
}

resource "azurerm_vpn_gateway_connection" "cato_vpn_gateway_connection" {
  name               = var.vpn_gateway_connection_name
  vpn_gateway_id     = azurerm_vpn_gateway.cato_vpn_gateway.id
  remote_vpn_site_id = azurerm_vpn_site.cato_vpn_site.id

  vpn_link {
    name             = var.vpn_site_primary_link_name
    vpn_site_link_id = azurerm_vpn_site.cato_vpn_site.link[0].id
    bandwidth_mbps = var.connection_bandwidth
    shared_key = random_password.shared_key_primary.result
    bgp_enabled = var.bgp_enabled
  }

  provisioner "local-exec" {
    command = <<EOT
    az network vpn-gateway show \
      --name "vpn-gateway-cato" \
      --resource-group ${local.resource_group_name} \
      --query "ipConfigurations[?id=='Instance0'].publicIpAddress" \
      --output tsv > azure_primary_public_ip.txt
    EOT
  }
}

data "local_file" "azure_primary_public_ip" {
  depends_on = [azurerm_vpn_gateway_connection.cato_vpn_gateway_connection]
  filename = "azure_primary_public_ip.txt"
}

resource "cato_ipsec_site" "vwan-hub" {
  name                 = var.site_name
  site_type            = "CLOUD_DC"
  description          = var.site_description
  native_network_range = data.azurerm_virtual_hub.hub.address_prefix
  site_location        = var.site_location
  ipsec = {
    primary = {
      public_cato_ip_id = var.cato_primary_public_ip
      tunnels = [
        {
          public_site_ip = replace(data.local_file.azure_primary_public_ip.content, "\n", "")
          private_site_ip = tolist(azurerm_vpn_gateway.cato_vpn_gateway.bgp_settings[0].instance_0_bgp_peering_address[0].default_ips)[0]
          private_cato_ip = var.cato_peering_address
          psk = random_password.shared_key_primary.result
          last_mile_bw = {
            downstream = var.connection_bandwidth
            upstream   = var.connection_bandwidth
          }
        }
      ]
    }
  }

  provisioner "local-exec" {
    command = <<EOF
      curl -k -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "x-API-Key: ${var.cato_token}" \
        '${var.cato_baseurl}' \
        --data '{
          "query": "mutation siteUpdateIpsecIkeV2SiteGeneralDetails($siteId: ID!, $updateIpsecIkeV2SiteGeneralDetailsInput: UpdateIpsecIkeV2SiteGeneralDetailsInput!, $accountId: ID!) { site(accountId: $accountId) { updateIpsecIkeV2SiteGeneralDetails(siteId: $siteId, input: $updateIpsecIkeV2SiteGeneralDetailsInput) { siteId localId } } }",
          "variables": {
            "accountId": ${var.cato_account_id},
            "siteId": "${cato_ipsec_site.vwan-hub.id}",
            "updateIpsecIkeV2SiteGeneralDetailsInput": {
              "initMessage": {
                "dhGroup": "DH_2_MODP1024"
              },
              "authMessage": {
                "dhGroup": "DH_2_MODP1024"
              },
              "networkRanges": "0:0.0.0.0/0"
            }
          },
          "operationName": "siteUpdateIpsecIkeV2SiteGeneralDetails"
        }'
      EOF
  }
}
