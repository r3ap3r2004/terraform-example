resource "aws_s3_bucket" "b" {
  for_each      = toset(var.bucket_names)
  bucket        = each.value
  force_destroy = true

  tags = {
    Name = each.value
  }
}
output "bucket_names" {
  value = [for b in aws_s3_bucket.b : b.id]
}
