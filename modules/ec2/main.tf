resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.sg_ids
  user_data     = var.user_data
  tags          = {
    Name        = "${var.name_prefix}-${var.role}"
    Role        = var.role
  }
  key_name      = var.key_name
}
output "id" { value = aws_instance.main.id }
output "public_ip" { value = aws_instance.main.public_ip }
