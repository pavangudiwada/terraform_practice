variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Resource Group Location"
  type        = string
  default     = "eastus"
}

variable "business_unit" {
  description = "Business Unit name"
  type        = string
  default     = "microsoft"
}

variable "virtual_network_name" {
  description = "Virtual Network Name"
  type        = string

}
variable "environment" {
  description = "Environment name"
  type        = set(string)
}


