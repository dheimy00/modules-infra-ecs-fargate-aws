# Example variables.tf file

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Whether to enable container insights"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "task_family" {
  description = "ECS Task Definition family"
  type        = string
}

variable "task_cpu" {
  description = "ECS Task CPU"
  type        = string
}

variable "task_memory" {
  description = "ECS Task memory"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "container_name" {
  description = "Name of the container in the ECS task definition"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = list(map(string))
}

variable "container_secrets" {
  description = "Secrets for the container"
  type        = list(map(string))
}

variable "log_group_name" {
  description = "Log group name for ECS task logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "task_definition_arn" {
  description = "ARN of the ECS task definition"
  type        = string
}

variable "desired_count" {
  description = "Desired number of running ECS tasks"
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS service"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to ECS tasks"
  type        = bool
}

variable "target_group_arn" {
  description = "ARN of the target group for the ECS service"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "alb_port" {
  description = "Port for the ALB listener"
  type        = number
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "internal_alb" {
  description = "Whether the ALB is internal"
  type        = bool
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "alb_ingress_cidr_blocks" {
  description = "CIDR blocks for ALB ingress rules"
  type        = list(string)
}

variable "codedeploy_service_role_arn" {
  description = "ARN of the CodeDeploy service role"
  type        = string
}

variable "prod_target_group_name" {
  description = "Name of the prod target group for ALB"
  type        = string
}

variable "blue_target_group_name" {
  description = "Name of the blue target group for ALB"
  type        = string
}
