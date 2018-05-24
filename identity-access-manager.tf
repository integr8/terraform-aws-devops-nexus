data "aws_iam_policy_document" "iam-policy_ec2-nexus-assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy_ecs-nexus-assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy_nexus-ec2-doc" {
  statement {
    actions = [
      "ecs:*",
      "s3:*",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "iam-policy_nexus-ecs-doc" {
  statement {
    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "ec2:AuthorizeSecurityGroupIngress",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "iam_nexus-ec2-role" {
  name               = "iam_nexus-ec2-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.iam-policy_ec2-nexus-assume.json}"
}

resource "aws_iam_role_policy" "iam-policy_nexus-ec2" {
  name   = "iam-policy_nexus-ec2"
  policy = "${data.aws_iam_policy_document.iam-policy_nexus-ec2-doc.json}"
  role   = "${aws_iam_role.iam_nexus-ec2-role.id}"
}

resource "aws_iam_role" "iam_nexus-ecs-role" {
  name               = "iam_nexus-ecs-role"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.iam-policy_ecs-nexus-assume.json}"
}

resource "aws_iam_role_policy" "iam-policy_nexus-ecs" {
  name   = "iam-policy_nexus-ecs"
  policy = "${data.aws_iam_policy_document.iam-policy_nexus-ecs-doc.json}"
  role   = "${aws_iam_role.iam_nexus-ecs-role.id}"
}
