variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS tasks and NLB"
  type        = list(string)
}

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image to run in the ECS task"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "listener_port" {
  description = "Port on which the NLB listener will listen"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory for the ECS task in MiB"
  type        = number
  default     = 512
}

variable "task_ephemeral_storage" {
  description = "Amount of ephemeral storage for the ECS task in GiB"
  type        = number
  default     = 21
}

variable "task_environment_vars" {
  description = "Environment variables for the ECS task"
  type        = map(string)
  default     = {}
}

variable "desired_count" {
  description = "Number of instances of the task to run"
  type        = number
  default     = 1
}

variable "nlb_internal" {
  description = "Whether the NLB is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the NLB"
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to the ECS tasks"
  type        = bool
  default     = false
}

variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks to allow inbound traffic from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_container_insights" {
  description = "Whether to enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Auto Scaling Variables
variable "min_capacity" {
  description = "Minimum number of tasks to run"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run"
  type        = number
  default     = 10
}

variable "enable_cpu_autoscaling" {
  description = "Whether to enable CPU-based auto scaling"
  type        = bool
  default     = true
}

variable "enable_memory_autoscaling" {
  description = "Whether to enable memory-based auto scaling"
  type        = bool
  default     = true
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "scale_in_cooldown" {
  description = "Cooldown period in seconds for scale in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period in seconds for scale out"
  type        = number
  default     = 300
}

variable "task_role_policy_statements" {
  description = "List of IAM policy statements for the ECS task role"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
} 