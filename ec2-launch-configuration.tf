data "template_file" "tpl_nexus-ecs-config" {
  template = file("${path.module}/custom/ecs.config")

  vars = {
    cluster-name = var.cluster-name
  }
}

data "template_file" "tpl_nexus-cloud-config" {
  template = file("${path.module}/custom/cloudinit.sh")

  vars = {
    bucket-name = aws_s3_bucket.s3_nexus.id
    efs-id      = aws_efs_file_system.efs_nexus.id
  }
}

resource "tls_private_key" "kp-create_nexus" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${tls_private_key.kp-create_nexus.private_key_pem}' > ${path.cwd}/outputs/kp_nexus"
  }
}

resource "aws_iam_instance_profile" "iam-ins-profile_nexus" {
  name = "iam-ins-profile_nexus"
  role = aws_iam_role.iam_nexus-ec2-role.id
}

resource "aws_key_pair" "kp_nexus" {
  key_name   = "kp_nexus"
  public_key = tls_private_key.kp-create_nexus.public_key_openssh

  depends_on = [tls_private_key.kp-create_nexus]
}

resource "random_id" "bucket-name" {
  byte_length = 12
  prefix      = var.bucket-name-prefix
}

resource "aws_s3_bucket" "s3_nexus" {
  bucket = random_id.bucket-name.hex
}

resource "aws_s3_bucket_object" "s3_nexus-object" {
  bucket  = aws_s3_bucket.s3_nexus.id
  key     = "ecs.config"
  content = data.template_file.tpl_nexus-ecs-config.rendered
}

resource "aws_launch_configuration" "launch-config_nexus" {
  name                 = "launch-config_nexus"
  image_id             = var.ami
  instance_type        = var.instance-type
  key_name             = aws_key_pair.kp_nexus.key_name
  user_data            = data.template_file.tpl_nexus-cloud-config.rendered
  iam_instance_profile = aws_iam_instance_profile.iam-ins-profile_nexus.id
  security_groups      = [aws_security_group.sg-ec2_nexus.id]
}

