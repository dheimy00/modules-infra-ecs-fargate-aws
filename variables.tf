# Declaring missing variables

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "enable_container_insights" {
  description = "Enable ECS container insights"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
}

variable "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
}

variable "log_group_name" {
  description = "The log group name for ECS task logs"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "container_name" {
  description = "The name of the container in the ECS task"
  type        = string
}

variable "container_image" {
  description = "The container image to use"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}

variable "container_environment" {
  description = "The environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "container_secrets" {
  description = "Secrets for the container"
  type        = list(object({
    name      = string
    valueFrom = string
  }))
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the ECS service"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "The ECS security group ID"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the ECS target group"
  type        = string
}

variable "alb_listener_arn" {
  description = "The ARN of the Application Load Balancer listener"
  type        = string
}

variable "internal_alb" {
  description = "Whether the ALB is internal or not"
  type        = bool
}

variable "security_groups" {
  description = "The security groups for the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID where the ECS service and ALB will be deployed"
  type        = string
}

variable "alb_port" {
  description = "The port on which the ALB will listen"
  type        = number
}

variable "alb_ingress_cidr_blocks" {
  description = "The CIDR blocks allowed for ingress to the ALB"
  type        = list(string)
}

variable "prod_target_group_name" {
  description = "The target group name for production"
  type        = string
}

variable "blue_target_group_name" {
  description = "The target group name for blue deployment"
  type        = string
}

variable "codedeploy_service_role_arn" {
  description = "The ARN of the CodeDeploy service role"
  type        = string
}

variable "desired_count" {
  description = "The desired number of ECS tasks"
  type        = number
}
