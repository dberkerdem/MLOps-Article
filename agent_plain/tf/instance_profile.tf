data "aws_iam_role" "this" {
  name = var.ec2_role_name
}

resource "aws_iam_instance_profile" "this" {
  name = format("%s_iam_instance_profile", var.instance_name)
  role = data.aws_iam_role.this.name
}
