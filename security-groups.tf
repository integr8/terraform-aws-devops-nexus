resource "aws_security_group" "sg_efs-nexus" {
  name        = "sg_efs-nexus-ingress"
  description = "Permite o trafico do EC2 para o EFS"
  vpc_id      = var.vpc-id

  tags = {
    Name = "sg_efs-nexus-ingress"
  }
}

resource "aws_security_group_rule" "sgr_efs-nexus-ingress" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sg_efs-nexus.id
  source_security_group_id = aws_security_group.sg-ec2_nexus.id
}

resource "aws_security_group" "sg-alb_nexus" {
  name        = "sg_alb_nexus"
  description = "Permite o trafego para no ALB"
  vpc_id      = var.vpc-id

  tags = {
    Name = "sg-alb_nexus"
  }
}

resource "aws_security_group_rule" "sgr-alb_nexus-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-alb_nexus.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sgr-alb_nexus-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg-alb_nexus.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "sg-ec2_nexus" {
  name        = "sg_ec2_nexus"
  description = "Permite o trafego para ao EC2"
  vpc_id      = var.vpc-id

  tags = {
    Name = "sg-ec2_nexus"
  }
}

resource "aws_security_group_rule" "sgr-ec2_nexus-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-ec2_nexus.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sgr-ec2_nexus-http" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.sg-ec2_nexus.id
  source_security_group_id = aws_security_group.sg-alb_nexus.id
}

resource "aws_security_group_rule" "srg-ec2_nexus-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-ec2_nexus.id
}

