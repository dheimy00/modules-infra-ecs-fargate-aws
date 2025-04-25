variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "task_definition_arn" {
  description = "The ECS task definition ARN"
  type        = string
}

variable "desired_count" {
  description = "Desired number of task instances"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to the ECS tasks"
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
