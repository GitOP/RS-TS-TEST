#
# Variables for all resources
#

variable "location" {
  description = "The location to use"
  type        = string
}

#
# Variables for virtual machine resources
#
variable "name" {
  description = "The name to assign to the virtual machine"
  type        = string
}

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
  description = "DigitalOcean SSH key IDs or fingerprints to add to the droplet"
  type        = list(string)
}
