terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Check if ECS cluster exists
data "aws_ecs_cluster" "existing" {
  count        = var.use_existing_cluster ? 1 : 0
  cluster_name = var.cluster_name
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  count = var.use_existing_cluster ? 0 : 1
  name  = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

locals {
  cluster_id   = var.use_existing_cluster ? data.aws_ecs_cluster.existing[0].id : aws_ecs_cluster.main[0].id
  cluster_name = var.use_existing_cluster ? data.aws_ecs_cluster.existing[0].cluster_name : aws_ecs_cluster.main[0].name
}

# Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.service_name}-nlb"
  internal           = var.nlb_internal
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name        = "${var.service_name}-tg"
  port        = var.container_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    port                = var.health_check_port
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
  }

  tags = var.tags
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.service_name}-service"
  cluster         = local.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_controller {
    type = "ECS"
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  force_new_deployment = true

  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [aws_ecs_task_definition.task]
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = var.tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  ephemeral_storage {
    size_in_gib = var.task_ephemeral_storage
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      environment = [
        for env_var in var.task_environment_vars : {
          name  = env_var.name
          value = env_var.value
        }
      ]
      secrets = [
        for secret in var.task_secrets : {
          name      = secret.name
          valueFrom = secret.valueFrom
        }
      ]
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = var.health_check_command
        interval    = var.container_health_check_interval
        timeout     = var.container_health_check_timeout
        retries     = var.health_check_retries
        startPeriod = var.health_check_start_period
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.service_name}"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.tags
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.service_name}-sg"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.is_private_subnet ? [1] : []
    content {
      protocol    = "tcp"
      from_port   = var.container_port
      to_port     = var.container_port
      cidr_blocks = [var.vpc_cidr]
      description = "Allow inbound traffic from VPC CIDR"
    }
  }

  dynamic "ingress" {
    for_each = var.is_private_subnet ? [] : [1]
    content {
      protocol    = "tcp"
      from_port   = var.container_port
      to_port     = var.container_port
      cidr_blocks = var.ingress_cidr_blocks
      description = "Allow inbound traffic from specified CIDR blocks"
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Auto Scaling IAM Role
resource "aws_iam_role" "ecs_autoscale_role" {
  name = "${var.service_name}-autoscale-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_role_policy" {
  role       = aws_iam_role.ecs_autoscale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${local.cluster_name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.ecs_autoscale_role.arn
}

# CPU Utilization Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.enable_cpu_autoscaling ? 1 : 0
  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# Memory Utilization Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  count              = var.enable_memory_autoscaling ? 1 : 0
  name               = "${var.service_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }
}

# Get current region
data "aws_region" "current" {} 