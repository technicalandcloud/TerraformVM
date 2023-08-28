variable "vm_name" {
  description = "VM names"
  default = "VM"
  type  = string
}

variable "vm_count" {
  description = "Number of VM"
  default = 108
  type = string
}
variable "nic_name" {
  description = "NIC names"
  default = "nic"
  type  = string
}
variable "nic" {
  description = "Number of nic"
  default = 108
  type = string
}
variable "secret_name" {
  description = "Name of secret"
  default = "secret"
  type = string
}
variable "secret" {
  description = "Number of secret KeyVault"
  default = 108
  type = string
}

variable "randomPassword" {
  description = "Number of random password"
  default = 108
  type = string
}
