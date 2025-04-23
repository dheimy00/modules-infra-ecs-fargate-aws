# AWS ECS Fargate Terraform Module

This Terraform module creates a complete AWS ECS Fargate infrastructure with the following components:

- ECS Cluster
- ECS Service
- ECS Task Definition
- Application Load Balancer
- CloudWatch Log Group
- IAM Roles and Policies
- Security Groups

## Usage

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  cluster_name = "my-cluster"
  service_name = "my-service"
  task_family  = "my-task"

  container_name  = "my-container"
  container_image = "my-image:latest"
  container_port  = 80

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678", "subnet-87654321"]

  # Optional parameters
  task_cpu    = 256
  task_memory = 512
  desired_count = 1

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| service_name | Name of the ECS service | `string` | n/a | yes |
| task_family | Family name of the ECS task definition | `string` | n/a | yes |
| container_name | Name of the container | `string` | n/a | yes |
| container_image | Docker image to use for the container | `string` | n/a | yes |
| container_port | Port exposed by the container | `number` | `80` | no |
| container_environment | Environment variables for the container | `list(map(string))` | `[]` | no |
| container_secrets | Secrets for the container | `list(map(string))` | `[]` | no |
| task_cpu | CPU units for the task | `number` | `256` | no |
| task_memory | Memory for the task in MB | `number` | `512` | no |
| desired_count | Number of instances of the task to run | `number` | `1` | no |
| vpc_id | ID of the VPC | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ECS tasks | `list(string)` | n/a | yes |
| assign_public_ip | Whether to assign public IP to the ECS tasks | `bool` | `false` | no |
| internal_alb | Whether the ALB is internal | `bool` | `true` | no |
| alb_port | Port for the ALB listener | `number` | `80` | no |
| alb_ingress_cidr_blocks | List of CIDR blocks allowed to access the ALB | `list(string)` | `["0.0.0.0/0"]` | no |
| health_check_path | Path for the ALB health check | `string` | `"/"` | no |
| enable_container_insights | Whether to enable CloudWatch Container Insights | `bool` | `true` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| service_name | Name of the ECS service |
| task_definition_arn | ARN of the task definition |
| task_execution_role_arn | ARN of the task execution role |
| task_role_arn | ARN of the task role |
| alb_dns_name | DNS name of the load balancer |
| alb_zone_id | Zone ID of the load balancer |
| target_group_arn | ARN of the target group |
| log_group_name | Name of the CloudWatch log group |

## Security

This module creates the following security components:

1. IAM Roles:
   - Task Execution Role with permissions to pull images and write logs
   - Task Role for application permissions

2. Security Groups:
   - ALB Security Group with configurable ingress rules
   - ECS Tasks Security Group with rules to allow traffic from the ALB

## Best Practices

1. Always use private subnets for ECS tasks unless public access is required
2. Use internal ALB when possible
3. Restrict ALB ingress CIDR blocks to specific IP ranges
4. Enable Container Insights for better monitoring
5. Set appropriate log retention period
6. Use appropriate CPU and memory values for your workload
7. Tag all resources for better resource management

## License

MIT 