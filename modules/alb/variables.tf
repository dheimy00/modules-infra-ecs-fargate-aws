variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "internal_alb" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "Security groups to attach to the ALB"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "vpc_id" {
  description = "VPC ID where the ALB resides"
  type        = string
}

variable "health_check_path" {
  description = "Path for the ALB health check"
  type        = string
  default     = "/"
}

variable "alb_port" {
  description = "Port for the ALB listener"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
