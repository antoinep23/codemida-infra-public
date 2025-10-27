locals {
  ecr_url   = "${var.ecr_repository_url}/${var.ecr_repository_name}"
  ecr_token = data.aws_ecr_authorization_token.this
}

data "aws_ecr_authorization_token" "this" {}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn
  container_definitions = jsonencode([
    {
      name        = var.app_name
      image       = "${local.ecr_url}:${var.image_version}"
      cpu         = 256
      memory      = 512
      essential   = true
      environment = var.envars
      secrets     = var.secrets
      portMappings = [
        {
          containerPort = var.port
          hostPort      = var.port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/codemida/${var.app_name}"
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/codemida/${var.app_name}"
  retention_in_days = 7
}

resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.app_security_group_id]
    assign_public_ip = var.is_public
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.app_name
    container_port   = var.port
  }
}

resource "aws_lb_target_group" "this" {
  vpc_id      = var.vpc_id
  port        = var.port
  name        = "${var.app_name}-ecs-tg"
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    enabled = true
    path    = var.healthcheck_path
  }
}

resource "aws_lb_listener_rule" "http_rule" {
  listener_arn = var.lb_listener_arn
  priority     = var.lb_priority

  condition {
    path_pattern {
      values = [var.path_pattern]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.task_max_capacity
  min_capacity       = 1
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  name               = "${var.app_name}-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60
    scale_out_cooldown = 90
    scale_in_cooldown  = 300
  }
}