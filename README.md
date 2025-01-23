# CATO IPSec Azure vWAN Terraform Module
This Terraform module provisions an IPSec connection between CATO Cloud and Azure vWAN. It creates primary and secondary tunnels for high availability (HA) and establishes a BGP connection to enable dynamic routing.

## Requirements
This terraform module requires:
- Two [Allocated IPs in CATO](https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account) Cloud
- [API Key in CATO](https://support.catonetworks.com/hc/en-us/articles/4413280536081-Generating-API-Keys-for-the-Cato-API)
- A configured vWAN and Hub
  - Note: A VPN gateway is not required, as it will be created by the module. 

## Providers

| Name                                                   | Version   |
|--------------------------------------------------------|-----------|
| <a name="provider_cato"></a> [cato](https://registry.terraform.io/providers/catonetworks/cato/latest)    | >= 0.0.12 |
| <a name="provider_azure"></a> [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest) | >= 4.1.0  | 

## Resources

| Name                                           | Type     |
|------------------------------------------------|----------|
| cato_allocatedIp                               | data     |
| [cato_ipsec_site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/ipsec_site)                            | resource |
| [azurerm_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip)                          | resource |
| [azurerm_virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway)            | resource |
| [azurerm_local_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway)              | resource |
| [azurerm_virtual_network_gateway_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |

## Inputs

| Name                        | Description                                  | Type          | Default                                        | Required |
|-----------------------------|----------------------------------------------|---------------|------------------------------------------------|:--------:|
| cato_baseurl                | Cato API base URL                           | `string`      | `https://api.catonetworks.com/api/v1/graphql2` |    no    |
| azure_subscription_id       | Azure subscription                          | `string`      |                                                |   yes    |
| azure_vwan_hub_id           | Azure vWAN Hub ID                           | `string`      |                                                |   yes    |
| cato_token                  | Cato API token                              | `string`      |                                                |   yes    |
| cato_account_id             | Cato account ID                             | `number`      |                                                |   yes    |
| site_name                   | Name of the Site                            | `string`      |                                                |   yes    |
| cato_site_address_cidrs     | Address CIDRs of the VPN Site               | `list(string)`|                                                |   yes    |
| connection_bandwidth        | VPN connection bandwidth (Mbps)             | `number`      | `10`                                           |    no    |
| vpn_site_primary_link_name  | Name of the primary VPN site link           | `string`      | `"primary"`                                    |    no    |
| vpn_site_secondary_link_name| Name of the secondary VPN site link         | `string`      | `"secondary"`                                  |    no    |
| site_description            | Description of the IPSec site               | `string`      | `"vWAN Hub"`                                   |    no    |
| site_location               | Site location details                       | `object`      |                                                |   yes    |
| cato_primary_public_ip      | Cato primary public IP                      | `string`      |                                                |   yes    |
| cato_secondary_public_ip    | Cato secondary public IP                    | `string`      |                                                |   yes    |
| bgp_enabled                 | BGP enabled                                 | `bool`        |                                                |   yes    |
| cato_asn                    | Cato ASN                                    | `number`      |                                                |   yes    |
| cato_primary_peering_address| Cato BGP peering IP address                 | `string`      |                                                |   yes    |
| cato_secondary_peering_address| Cato BGP peering IP address               | `string`      |                                                |   yes    |
| vpn_gateway_connection_name | Azure VPN gateway connection name           | `string`      | `"vpn-gateway-connection-cato"`                |    no    |
| vpn_gateway_name            | Azure VPN gateway name                      | `string`      | `"vpn-gateway-cato"`                           |    no    |
| vpn_site_name               | Azure VPN site name                         | `string`      | `"vpn-site-cato"`                              |    no    |


## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-ipsec-aws/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-ipsec-aws/tree/master/LICENSE) for full details.
