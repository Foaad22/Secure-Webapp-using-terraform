variable "instance_type"     { type = string }
variable "subnet_id"         { type = string }
variable "sg_ids"            { type = list(string) }
variable "name"              { type = string }
variable "bastion_host" {
  description = "Public IP of the bastion (reverse proxy) host"
  type        = string
}

variable "bastion_private_key_path" {
  description = "Path to the private key for SSH via bastion"
  type        = string
}


