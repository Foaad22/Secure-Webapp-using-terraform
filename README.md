# 🚀 Secure Web Application Infrastructure with Terraform

This project provisions a complete **secure web application infrastructure** on AWS using **Terraform** 



### ✅ Components Deployed:
- **VPC** with custom CIDR
- **Public & Private Subnets** (across 2 AZs)
- **Internet Gateway & NAT Gateway**
- **Security Groups** (for Proxy, Backend, ALBs)
- **EC2 Instances**
  - 2x Reverse Proxy (Nginx)
  - 2x Apache Backend servers
- **Application Load Balancers**
  - Public-facing ALB for Proxies
  - Internal ALB for Backend
- **Bastion Host**
  - Reverse Proxy used for SSH access to private backend instances
- **Local Provisioner**
  - Collects public/private IPs of instances into `all_ips.txt`

---

## ⚙️ Requirements

- AWS CLI configured with your credentials
- Terraform >= 1.0
- SSH keypair (you should update `key_name` and `prkey.pem` path)

---

## 🚀 How to Deploy

```bash
git clone https://github.com/Foaad22/Secure-Webapp-using-terraform.git
cd Secure-Webapp-using-terraform
terraform init
terraform plan
terraform apply

Accessing the App
After deployment:

Go to the output of terraform output public_alb_dns
Visit:
http://<public_alb_dns>
replace <public_alb_dns> with the value of "public_lb_dns" output 
You should see:

Hello from backend website



🛠️ Customization
You can modify the following in main.tf:

CIDR ranges for VPC & subnets

Instance types (t2.micro → other)

AMIs

Security group rules

Nginx proxy configuration

👤 Author
@Foaad22









