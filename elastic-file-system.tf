resource "aws_efs_file_system" "efs_nexus" {
  tags = {
    Name = "efs_nexus"
  }
}

resource "aws_efs_mount_target" "efs-mt_nexus-public-1" {
  file_system_id  = aws_efs_file_system.efs_nexus.id
  subnet_id       = element(var.subnets, 0)
  security_groups = [aws_security_group.sg_efs-nexus.id]
}

resource "aws_efs_mount_target" "efs-mt_nexus-public-2" {
  file_system_id  = aws_efs_file_system.efs_nexus.id
  subnet_id       = element(var.subnets, 1)
  security_groups = [aws_security_group.sg_efs-nexus.id]
}

