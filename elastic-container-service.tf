resource "aws_ecs_cluster" "ecs-cluster_nexus" {
  name = var.cluster-name
}

resource "aws_appautoscaling_target" "ecs-as-target_nexus" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-cluster_nexus.name}/${aws_ecs_service.ecs-service_nexus.name}"
  role_arn           = aws_iam_role.iam_nexus-ecs-role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_ecs_task_definition" "ecs-tf_nexus" {
  family                = "nexus-node"
  container_definitions = file("${path.module}/custom/task-definition/nexus.json")
  network_mode          = "bridge"

  volume {
    name      = "nexus-data"
    host_path = "/data"
  }
}

resource "aws_ecs_service" "ecs-service_nexus" {
  name            = "nexus-service"
  cluster         = aws_ecs_cluster.ecs-cluster_nexus.arn
  task_definition = aws_ecs_task_definition.ecs-tf_nexus.arn
  desired_count   = 2
  iam_role        = aws_iam_role.iam_nexus-ecs-role.id

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-tg-nexus.id
    container_name   = "nexus-node"
    container_port   = 8081
  }

  depends_on = [
    aws_alb_target_group.alb-tg-nexus,
    aws_alb.alb-nexus,
  ]
}

