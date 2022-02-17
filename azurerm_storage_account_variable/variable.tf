variable "resource_group_name" {
  description = "Name of the resource group"
}

variable "location" {
  description = "Location of the resource group"
}

variable "sa_name" {
  description = "Storage account name"
}

variable "account_tire" {
    description = "Account tire"
    default = "Storage"
}

variable "replication_type" {
  description = "Replicaiton Type"
  default = "LRS"
}
variable "blobpublic_access" {
  default = true
}