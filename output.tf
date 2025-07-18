output "public_lb_dns" {
  value       = module.lb_reverse_proxy.alb_dns_name
}
