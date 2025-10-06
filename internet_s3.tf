# bad_s3.tf
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "wiz-testing-public-bucket-example"
  acl    = "public-read"              # ← 公開バケット（データ露出）
  tags = {
    Env = "test"
  }
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Allow everything (bad)"
  vpc_id      = "vpc-12345678"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]       # ← 全開
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "overprivileged" {
  name = "overpriv-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

resource "aws_iam_policy" "full_policy" {
  name        = "full-policy"
  description = "Very broad policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "*",                    # ← 過剰権限
    "Effect": "Allow",
    "Resource": "*"
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.overprivileged.name
  policy_arn = aws_iam_policy.full_policy.arn
}
