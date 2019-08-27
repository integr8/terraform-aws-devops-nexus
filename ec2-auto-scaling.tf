resource "aws_autoscaling_group" "asg_nexus" {
  name                 = "asg_nexus"
  launch_configuration = aws_launch_configuration.launch-config_nexus.id
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  vpc_zone_identifier       = [element(var.subnets, 0)]
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 400
  target_group_arns         = [aws_alb_target_group.alb-tg-nexus.id]

  depends_on = [
    aws_efs_file_system.efs_nexus,
    aws_efs_mount_target.efs-mt_nexus-public-1,
    aws_efs_mount_target.efs-mt_nexus-public-2,
  ]

  tags = [
    {
      key                 = "Name"
      value               = "nexus-scale-group"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_policy" "asp_nexus-scale-up" {
  name                      = "asp_nexus-scale-up"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = aws_autoscaling_group.asg_nexus.name
  estimated_instance_warmup = 60
  metric_aggregation_type   = "Average"
  policy_type               = "StepScaling"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 2
  }
}

resource "aws_cloudwatch_metric_alarm" "cw-alarm_nexus-scale-up" {
  alarm_name          = "cw-alarm_nexus-scale-up"
  alarm_description   = "O uso de CPU atingiu 70% no ultimo minuto"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Maximum"
  threshold           = 70
  period              = 60
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_autoscaling_policy.asp_nexus-scale-up.arn]

  dimensions = {
    Name  = "ClusterName"
    Value = var.cluster-name
  }
}

resource "aws_autoscaling_policy" "asp_nexus-scale-down" {
  name                   = "asp_nexus-scale-down"
  adjustment_type        = "PercentChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg_nexus.name
  cooldown               = 120
  scaling_adjustment     = -50
}

resource "aws_cloudwatch_metric_alarm" "cw-alarm_nexus-scale-down" {
  alarm_name          = "cw-alarm_nexus-scale-down"
  alarm_description   = "O uso de CPU está abaixo de 50% nos últimos 10 minutos"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  comparison_operator = "LessThanThreshold"
  statistic           = "Maximum"
  threshold           = 50
  period              = 600
  evaluation_periods  = 1
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_autoscaling_policy.asp_nexus-scale-down.arn]

  dimensions = {
    Name  = "ClusterName"
    Value = var.cluster-name
  }
}

