data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "reverse_proxy" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = var.sg_ids
  key_name                    = "my key"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./../prkey.pem")
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "echo public ip for ${var.name} is: ${self.public_ip} >> all_ips.txt"
  }

  provisioner "remote-exec" {
  inline = [
    "sudo amazon-linux-extras enable nginx1",
    "sudo yum clean metadata",
    "sudo yum install -y nginx",
    "echo 'server {\n  listen 80;\n  location / {\n    proxy_pass http://${var.backend_lb_dns};\n  }\n}' | sudo tee /etc/nginx/conf.d/default.conf",
    "sudo systemctl enable --now nginx"
  ]
}
  tags = {
    Name = var.name
  }
}
