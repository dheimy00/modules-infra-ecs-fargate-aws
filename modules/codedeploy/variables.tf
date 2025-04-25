variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "codedeploy_service_role_arn" {
  description = "CodeDeploy service role ARN"
  type        = string
}

variable "alb_listener_arn" {
  description = "ALB listener ARN"
  type        = string
}

variable "prod_target_group_name" {
  description = "Target group name for production"
  type        = string
}

variable "blue_target_group_name" {
  description = "Target group name for blue"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
