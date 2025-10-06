#
# Variables for all resources
#

variable "location" {
  description = "The location to use"
  type        = string
}
# variable "resource_tags" {
#   description = "Tags to assign to all resources created by this module"
#   type        = map(string)
# }

#
# Variables for virtual machine resources
#
variable "name" {
  description = "The name to assign to the virtual machine"
  type        = string
}
# variable "primary_subnet_id" {
#   description = "The primary subnet (typically PUBLIC) to assign to the virtual machine"
#   type        = string
# }
variable "vpc_uuid" {
  description = "The vpc to assign to the virtual machine"
  type        = string
  default = ""
}
variable "size" {
  description = "The droplet size to assign the virtual machine"
  type        = string
}
variable "image" {
  description = "The droplet image to assign the virtual machine"
  type        = string
}
variable "ssh_keys" {
  description = "The name of the SSH public key to assign to the virtual machine"
  type        = list(string)
}
