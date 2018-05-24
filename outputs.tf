output "nexus-loadbalancer-dns-name" {
  value = "${aws_alb.alb-nexus.dns_name}"
}
