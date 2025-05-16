resource "aws_iam_role" "read_only" {
  name = "${var.name_prefix}-${var.service}-ro"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role" "read_write" {
  name = "${var.name_prefix}-${var.service}-rw"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
output "ro_role" { value = aws_iam_role.read_only.name }
output "rw_role" { value = aws_iam_role.read_write.name }