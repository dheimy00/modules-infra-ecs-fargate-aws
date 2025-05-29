variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "use_existing_cluster" {
  description = "Whether to use an existing ECS cluster instead of creating a new one"
  type        = bool
  default     = false
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

variable "is_private_subnet" {
  description = "Whether the subnets are private. If true, only allows traffic from VPC CIDR"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
  default     = null
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

variable "host_port" {
  description = "Port on the host to map to the container port"
  type        = number
  default     = null
}

variable "task_secrets" {
  description = "List of secrets to pass to the container"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# Health Check Variables
variable "health_check_protocol" {
  description = "Protocol to use for health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Port to use for health check"
  type        = string
  default     = "traffic-port"
}

variable "health_check_path" {
  description = "Path to use for health check"
  type        = string
  default     = "/health"
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks required to mark target as healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks required to mark target as unhealthy"
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Interval between health checks in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health check in seconds"
  type        = number
  default     = 5
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

variable "health_check_command" {
  description = "Command to run for container health check"
  type        = list(string)
  default     = []
}

variable "health_check_retries" {
  description = "Number of retries for container health check"
  type        = number
  default     = 3
}

variable "health_check_start_period" {
  description = "Grace period in seconds for container health check"
  type        = number
  default     = 60
} 