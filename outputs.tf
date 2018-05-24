output "nexus" {
  value = "${aws_alb.alb-nexus.dns_name}"
}
