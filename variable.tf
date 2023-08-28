variable "resource_group_location" {
  type        = string
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-terraform"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "vm_name" {
  description = "VM names"
  default = "VM-"
  type  = string
}

variable "vm_count" {
  description = "Nombre de VM"
  default = 5
  type = string
}
variable "nic_name" {
  description = "NIC names"
  default = "nic"
  type  = string
}
variable "nic" {
  description = "Nombre de nic"
  default = 5
  type = string
}