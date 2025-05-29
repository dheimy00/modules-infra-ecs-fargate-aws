# AWS ECS Fargate Module

This Terraform module creates a complete ECS Fargate service with the following features:

- ECS Cluster with Fargate launch type (or use existing cluster)
- ECS Service with task definition
- Network Load Balancer (NLB)
- Auto Scaling with CPU and Memory utilization
- CloudWatch Logs integration
- IAM roles and policies
- Security groups with private/public subnet support
- Secrets management support
- Configurable health checks

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Usage

### Basic Usage

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  project_name = "my-app"
  vpc_id       = "vpc-123456"
  subnet_ids   = ["subnet-123456", "subnet-789012"]

  # Use existing cluster
  use_existing_cluster = true

  container_image = "my-app:latest"
  container_port  = 8080

  task_cpu    = 256
  task_memory = 512

  desired_count = 2
  min_capacity  = 1
  max_capacity  = 5

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### Advanced Usage with All Features

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  # Basic Configuration
  project_name = "my-app"
  vpc_id       = "vpc-123456"
  subnet_ids   = ["subnet-123456", "subnet-789012"]

  # Container Configuration
  container_name  = "app"
  container_image = "my-app:latest"
  container_port  = 8080
  host_port       = 8080

  # Task Configuration
  task_cpu              = 256
  task_memory           = 512
  task_ephemeral_storage = 21
  task_environment_vars = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "info"
  }

  # Network Configuration
  is_private_subnet = true 
  vpc_cidr          = "10.0.0.0/16"

  is_private_subnet = false
  ingress_cidr_blocks = ["0.0.0.0/0"]  # or specific IP ranges

  nlb_internal      = true
  assign_public_ip  = false

  # Auto Scaling Configuration
  desired_count = 2
  min_capacity  = 1
  max_capacity  = 5
  enable_cpu_autoscaling    = true
  enable_memory_autoscaling = true
  cpu_target_value         = 70
  memory_target_value      = 70
  scale_in_cooldown        = 300
  scale_out_cooldown       = 300

  # Health Check Configuration
  health_check_protocol = "HTTP"
  health_check_path     = "/health"
  health_check_port     = "traffic-port"
  health_check_command  = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]

  # Secrets Configuration
  task_secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:region:account:secret:db-password"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:ssm:region:account:parameter/api-key"
    }
  ]

  # IAM Policy Configuration
  task_role_policy_statements = [
    {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]

  # Monitoring Configuration
  enable_container_insights = true
  log_retention_days       = 30

  tags = {
    Environment = "production"
    Project     = "my-app"
    Terraform   = "true"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used for resource naming | `string` | n/a | yes |
| use_existing_cluster | Whether to use an existing ECS cluster instead of creating a new one | `bool` | `false` | no |
| vpc_id | ID of the VPC where resources will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ECS tasks and NLB | `list(string)` | n/a | yes |
| container_name | Name of the container | `string` | `"app"` | no |
| container_image | Docker image to run in the ECS task | `string` | n/a | yes |
| container_port | Port exposed by the container | `number` | `80` | no |
| host_port | Port on the host to map to the container port | `number` | `null` | no |
| listener_port | Port on which the NLB listener will listen | `number` | `80` | no |
| task_cpu | CPU units for the ECS task | `number` | `256` | no |
| task_memory | Memory for the ECS task in MiB | `number` | `512` | no |
| task_ephemeral_storage | Amount of ephemeral storage for the ECS task in GiB | `number` | `21` | no |
| task_environment_vars | Environment variables for the ECS task | `map(string)` | `{}` | no |
| task_secrets | List of secrets to pass to the container | `list(object)` | `[]` | no |
| desired_count | Number of instances of the task to run | `number` | `1` | no |
| is_private_subnet | Whether the subnets are private | `bool` | `false` | no |
| vpc_cidr | CIDR block of the VPC | `string` | `null` | no |
| nlb_internal | Whether the NLB is internal | `bool` | `false` | no |
| enable_deletion_protection | Whether to enable deletion protection for the NLB | `bool` | `false` | no |
| assign_public_ip | Whether to assign public IP to the ECS tasks | `bool` | `false` | no |
| ingress_cidr_blocks | List of CIDR blocks to allow inbound traffic from | `list(string)` | `["0.0.0.0/0"]` | no |
| enable_container_insights | Whether to enable CloudWatch Container Insights | `bool` | `true` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` | no |
| min_capacity | Minimum number of tasks to run | `number` | `1` | no |
| max_capacity | Maximum number of tasks to run | `number` | `10` | no |
| enable_cpu_autoscaling | Whether to enable CPU-based auto scaling | `bool` | `true` | no |
| enable_memory_autoscaling | Whether to enable memory-based auto scaling | `bool` | `true` | no |
| cpu_target_value | Target CPU utilization percentage for auto scaling | `number` | `70` | no |
| memory_target_value | Target memory utilization percentage for auto scaling | `number` | `70` | no |
| scale_in_cooldown | Cooldown period in seconds for scale in | `number` | `300` | no |
| scale_out_cooldown | Cooldown period in seconds for scale out | `number` | `300` | no |
| health_check_protocol | Protocol to use for health check | `string` | `"HTTP"` | no |
| health_check_port | Port to use for health check | `string` | `"traffic-port"` | no |
| health_check_path | Path to use for health check | `string` | `"/health"` | no |
| health_check_healthy_threshold | Number of consecutive successful health checks required | `number` | `3` | no |
| health_check_unhealthy_threshold | Number of consecutive failed health checks required | `number` | `3` | no |
| health_check_interval | Interval between health checks in seconds | `number` | `30` | no |
| health_check_timeout | Timeout for health check in seconds | `number` | `5` | no |
| health_check_matcher | HTTP codes to use for successful response | `string` | `"200"` | no |
| health_check_command | Command to run for container health check | `list(string)` | `["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]` | no |
| health_check_retries | Number of retries for container health check | `number` | `3` | no |
| health_check_start_period | Grace period in seconds for container health check | `number` | `60` | no |
| task_role_policy_statements | List of IAM policy statements for the ECS task role | `list(object)` | `[]` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the ECS cluster |
| cluster_name | The name of the ECS cluster |
| service_name | The name of the ECS service |
| task_definition_arn | The ARN of the task definition |
| load_balancer_dns | The DNS name of the load balancer |
| target_group_arn | The ARN of the target group |
| task_execution_role_arn | The ARN of the task execution role |
| task_role_arn | The ARN of the task role |

## Important Notes

### Deployment Controller
- The service uses the ECS deployment controller by default
- This controller provides rolling updates and blue/green deployments
- Supports deployment circuit breaker for automatic rollback on failures
- Allows for gradual traffic shifting during deployments
- Deployment configuration:
  - Minimum healthy percent: 100% (ensures full capacity during deployments)
  - Maximum percent: 200% (allows doubling of capacity during deployments)
  - Force new deployment: Enabled (ensures new task definition is used)
  - Create before destroy: Enabled (zero-downtime updates)
  - Replace triggered by task definition changes (automatic updates)

### Security Groups and Subnets
- For private subnets:
  - Set `is_private_subnet = true`
  - Provide `vpc_cidr` to allow traffic only from within the VPC
  - Traffic is restricted to the VPC CIDR range
- For public subnets:
  - Set `is_private_subnet = false`
  - Use `ingress_cidr_blocks` to specify allowed IP ranges
  - Default allows traffic from anywhere (0.0.0.0/0)

### Health Checks
- For TCP health checks, `path` and `matcher` parameters are not applicable
- Container health check command should return a non-zero exit code on failure
- The default health check command uses curl to check the `/health` endpoint
- Health check grace period (startPeriod) allows containers time to initialize

### Secrets
- Task execution role needs permissions to access secrets
- Secrets can be stored in AWS Secrets Manager or Systems Manager Parameter Store
- The `valueFrom` should be the full ARN of the secret
- Secrets are available as environment variables in the container

### Network Load Balancer
- NLB uses TCP protocol by default
- Health check protocol can be HTTP, HTTPS, or TCP
- For HTTP/HTTPS health checks, path and matcher are required
- For TCP health checks, only port and protocol are used

### Auto Scaling
- CPU and memory-based auto scaling are enabled by default
- Target values are set to 70% utilization by default
- Cooldown periods prevent rapid scaling events
- Minimum and maximum capacity can be adjusted as needed

### IAM Roles
- Task Execution Role: Used by ECS to pull container images and write logs
- Task Role: Used by your application running in the container
- Custom policy statements can be added to the task role
- Default policies provide basic ECS functionality

### Monitoring
- CloudWatch Container Insights is enabled by default
- Logs are retained for 30 days by default
- Log group name format: `/ecs/{project_name}`
- Metrics are available for CPU, memory, and network usage

## License

MIT Licensed. See LICENSE for full details. 