variable "instance_type" {}
variable "subnet_id" {}
variable "sg_ids" {
  type = list(string)
}

variable "backend_lb_dns" {}
variable "name" {}
