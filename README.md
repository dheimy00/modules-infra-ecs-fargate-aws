# AWS ECS Fargate Module

This Terraform module creates a complete ECS Fargate service with the following features:

- ECS Cluster with Fargate launch type
- ECS Service with task definition
- Network Load Balancer (NLB)
- Auto Scaling with CPU and Memory utilization
- CloudWatch Logs integration
- IAM roles and policies
- Security groups

## Usage

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  project_name = "my-app"
  vpc_id       = "vpc-123456"
  subnet_ids   = ["subnet-123456", "subnet-789012"]

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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used for resource naming | `string` | n/a | yes |
| vpc_id | ID of the VPC where resources will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ECS tasks and NLB | `list(string)` | n/a | yes |
| container_name | Name of the container | `string` | `"app"` | no |
| container_image | Docker image to run in the ECS task | `string` | n/a | yes |
| container_port | Port exposed by the container | `number` | `80` | no |
| listener_port | Port on which the NLB listener will listen | `number` | `80` | no |
| task_cpu | CPU units for the ECS task | `number` | `256` | no |
| task_memory | Memory for the ECS task in MiB | `number` | `512` | no |
| task_ephemeral_storage | Amount of ephemeral storage for the ECS task in GiB | `number` | `21` | no |
| task_environment_vars | Environment variables for the ECS task | `map(string)` | `{}` | no |
| desired_count | Number of instances of the task to run | `number` | `1` | no |
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

## Auto Scaling

The module configures auto scaling based on CPU and memory utilization. By default:
- CPU utilization target: 70%
- Memory utilization target: 70%
- Scale in cooldown: 300 seconds
- Scale out cooldown: 300 seconds

You can adjust these values using the respective variables.

## IAM Roles

The module creates two IAM roles:
1. Task Execution Role: Used by ECS to pull container images and write logs
2. Task Role: Used by your application running in the container

You can add custom policy statements to the task role using the `task_role_policy_statements` variable.

## Security

- The module creates a security group that allows inbound traffic on the container port
- By default, it allows traffic from all IPs (0.0.0.0/0)
- You can restrict this using the `ingress_cidr_blocks` variable

## Logging

- Container logs are sent to CloudWatch Logs
- Log group name format: `/ecs/{project_name}`
- Default log retention: 30 days
- Container Insights is enabled by default

## License

MIT Licensed. See LICENSE for full details. 