# AWS ECS Fargate Module

This Terraform module creates a complete ECS Fargate service with the following features:

- ECS Cluster with Fargate launch type (or use existing cluster)
- ECS Service with task definition
- Network Load Balancer (NLB) with TCP support
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

### Required AWS Services
- VPC with at least two subnets in different Availability Zones
- Internet Gateway (for public subnets)
- NAT Gateway (for private subnets)
- Route Tables configured for the subnets
- IAM permissions for ECS, NLB, and CloudWatch

## Usage

### Basic Usage

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  service_name = "my-app"
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

### Advanced Usage with NLB Configuration

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  # Basic Configuration
  service_name = "my-app"
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
  nlb_internal      = true
  assign_public_ip  = false

  # Health Check Configuration
  health_check_port                = "traffic-port"
  health_check_healthy_threshold   = 3
  health_check_unhealthy_threshold = 3
  health_check_interval           = 30
  health_check_timeout            = 5
  container_health_check_interval = 30
  container_health_check_timeout  = 5

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

## Important Notes

### Network Load Balancer (NLB)
- Uses TCP protocol for traffic
- No security groups required (operates at transport layer)
- Health checks are TCP-based
- Supports both internal and internet-facing configurations
- Health check configuration is simpler than ALB
- No path-based or host-based routing (operates at TCP layer)

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
- Health checks are TCP-based
- No HTTP/HTTPS specific configurations needed
- Container health check command should return a non-zero exit code on failure
- Health check grace period (startPeriod) allows containers time to initialize
- Container-level health checks:
  - Configured using `health_check_command`
  - Default command uses curl to check the health endpoint
  - Custom commands can be specified as a list of strings
  - Example: `["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]`
  - Must return exit code 0 for success, non-zero for failure
  - Retries and start period can be configured
  - Separate interval and timeout settings from target group health checks
- NLB target group health checks:
  - Configured using TCP protocol
  - Used to determine if the container is healthy for traffic routing
  - Independent of container-level health checks
  - Separate interval and timeout settings from container health checks

### Container HealthCheck Configuration
The module configures container health checks in the ECS task definition with the following parameters:

```hcl
healthCheck = {
  command     = var.health_check_command
  interval    = var.health_check_interval
  timeout     = var.health_check_timeout
  retries     = var.health_check_retries
  startPeriod = var.health_check_start_period
}
```

#### HealthCheck Parameters
- `command`: The command to run to check container health
  - Must be a list of strings
  - First element is typically "CMD-SHELL"
  - Example: `["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]`
  - Should return exit code 0 for healthy, non-zero for unhealthy
  - Can use any command available in the container

- `interval`: Time between health checks (seconds)
  - Default: 30 seconds
  - Minimum: 5 seconds
  - Maximum: 300 seconds
  - Should be longer than the timeout

- `timeout`: Time to wait for health check to complete (seconds)
  - Default: 5 seconds
  - Minimum: 2 seconds
  - Maximum: 60 seconds
  - Should be shorter than the interval

- `retries`: Number of consecutive failures before marking unhealthy
  - Default: 3
  - Minimum: 1
  - Maximum: 10
  - Helps prevent false negatives

- `startPeriod`: Grace period for container startup (seconds)
  - Default: 60 seconds
  - Minimum: 0 seconds
  - Maximum: 300 seconds
  - Allows time for application initialization

#### Best Practices
1. Command Configuration:
   - Use absolute paths in commands
   - Include proper error handling
   - Consider container resource constraints
   - Test commands locally before deployment

2. Timing Configuration:
   - Set appropriate intervals based on application needs
   - Ensure timeout is less than interval
   - Consider application startup time for startPeriod
   - Balance between responsiveness and resource usage

3. Retry Configuration:
   - Set retries based on application stability
   - Consider network latency and temporary issues
   - Avoid too many retries to prevent delayed failure detection

4. Integration with NLB:
   - Align container health check with NLB health check
   - Consider using the same health endpoint
   - Ensure consistent success criteria
   - Monitor both health check types

5. Monitoring:
   - Set up CloudWatch alarms for health check failures
   - Monitor health check metrics
   - Track container restarts
   - Review health check logs

### Secrets
- Task execution role needs permissions to access secrets
- Secrets can be stored in AWS Secrets Manager or Systems Manager Parameter Store
- The `valueFrom` should be the full ARN of the secret
- Secrets are available as environment variables in the container

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
- Log group name format: `/ecs/{service_name}`
- Metrics are available for CPU, memory, and network usage

## License

MIT Licensed. See LICENSE for full details. 