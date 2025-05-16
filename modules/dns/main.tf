resource "aws_route53_record" "rec" {
  zone_id = var.zone_id
  name    = var.name
  type    = "A"
  ttl     = 300
  records = [var.ip]
}