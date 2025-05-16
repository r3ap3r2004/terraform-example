resource "aws_security_group" "main" {
  name        = "${var.name_prefix}-${var.role}-sg"
  description = "Security group for ${var.role}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-${var.role}-sg"
  }
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each = { for idx, rule in var.ingress : idx => rule if length(rule.cidr_blocks) > 0 }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "ingress_sg_refs" {
  for_each = { for idx, rule in var.sg_ingress : idx => rule }
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_sg
  security_group_id        = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress_cidr" {
  for_each = { for idx, rule in var.egress : idx => rule if length(rule.cidr_blocks) > 0 }
  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "egress_sg_refs" {
  for_each = { for idx, rule in var.sg_egress : idx => rule }
  type                     = "egress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_sg
  security_group_id        = aws_security_group.main.id
}
