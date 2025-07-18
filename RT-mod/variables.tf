variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type = string
}

variable "nat_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "public_subnet_map" {
  type = map(string)
  description = "Map of public subnet names to subnet IDs"
}

variable "private_subnet_map" {
  type = map(string)
  description = "Map of private subnet names to subnet IDs"
}

