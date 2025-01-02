variable "cato_baseurl" {
  description = "Cato API base URL"
  type        = string
  default     = "https://api.catonetworks.com/api/v1/graphql2"
}

variable "azure_subscription_id" {
  description = "Azure subscription"
  type = string
}

variable "azure_vwan_hub_id" {
  description = "Azure vWAN Hub ID"
  type = string
}

variable "cato_token" {
  description = "Cato API token"
  type        = string
}

variable "cato_account_id" {
  description = "Cato account ID"
  type        = number
}

variable "site_name" {
  description = "Name of the Site"
  type        = string
}

variable "cato_site_address_cidrs" {
  description = "Address CIDRs of the VPN Site"
  type        = list(string)
}

variable "connection_bandwidth" {
  description = "VPN connection bandwidth (Mbps)"
  type        = number
  default     = 10
}

variable "vpn_site_primary_link_name" {
  type        = string
  default     = "primary"
}

variable "site_description" {
  description = "Description of the IPSec site"
  type        = string
  default     = "vWAN Hub"
}

variable "site_location" {
  type = object({
    city         = string
    country_code = string
    state_code   = string
    timezone     = string
  })
}

variable "primary_public_cato_ip_id" {
  description = "Primary tunnel POP location ID"
  type        = number
}

variable "bgp_enabled" {
  description = "BGP enabled"
  type = bool
}

variable "cato_asn" {
  description = "Cato ASN"
  type = number
}

variable "cato_peering_address" {
  description = "Cato BGP peering IP address"
  type = string
}

variable "vpn_gateway_connection_name" {
  description = "Azure VPN gateway connection name"
  type = string
  default = "vpn-gateway-connection-cato"
}

variable "vpn_gateway_name" {
  description = "Azure VPN gateway name"
  type = string
  default = "vpn-gateway-cato"
}

variable "vpn_site_name" {
  description = "Azure VPN site name"
  type = string
  default = "vpn-site-cato"
}

