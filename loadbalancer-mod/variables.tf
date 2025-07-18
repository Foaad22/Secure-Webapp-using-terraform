variable "name_prefix" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "port" {
  type = number
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "instance_map" {
  description = "Map of instance names to instance IDs"
  type        = map(string)
}
