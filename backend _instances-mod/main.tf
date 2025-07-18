data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "apache" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  key_name               = "my key"

    provisioner "file" {
    source      = "./../prkey.pem"
    destination = "/home/ec2-user/app"

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ec2-user"
      private_key         = file("./../prkey.pem")
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }

  provisioner "local-exec" {
    command = "echo public ip for ${var.name} is: ${self.private_ip} >> all_ips.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "echo 'hello from backend website' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable --now httpd"
    ]

    connection {
      type                = "ssh"
      host                = self.private_ip
      user                = "ec2-user"
      private_key         = file("./../prkey.pem")
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
  tags = {
    Name = var.name
  }
}