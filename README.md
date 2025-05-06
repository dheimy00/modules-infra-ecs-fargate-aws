# AWS ECS Fargate with Network Load Balancer Terraform Module

This Terraform module creates an ECS Fargate cluster with a Network Load Balancer (NLB) in AWS. It includes all necessary resources such as ECS cluster, service, task definition, NLB, target group, security groups, and CloudWatch log groups.

## Features

- ECS Fargate cluster with Container Insights
- Network Load Balancer (NLB)
- ECS Service with Fargate launch type
- Task Definition with configurable CPU and memory
- Security Group for ECS tasks
- CloudWatch Log Group for container logs
- IAM roles and policies for task execution

## Usage

```hcl
module "ecs_fargate" {
  source = "path/to/module"

  cluster_name    = "my-ecs-cluster"
  vpc_id         = "vpc-12345678"
  subnet_ids     = ["subnet-12345678", "subnet-87654321"]
  
  container_name  = "my-app"
  container_image = "my-app:latest"
  container_port  = 80
  
  task_cpu    = 256
  task_memory = 512
  
  desired_count = 2
  
  nlb_internal = false
  
  tags = {
    Environment = "production"
    Project     = "my-project"
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
| cluster_name | Name of the ECS cluster | `string` | n/a | yes |
| vpc_id | ID of the VPC where resources will be created | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for the ECS tasks and NLB | `list(string)` | n/a | yes |
| container_name | Name of the container | `string` | `"app"` | no |
| container_image | Docker image to run in the ECS task | `string` | n/a | yes |
| container_port | Port exposed by the container | `number` | `80` | no |
| listener_port | Port on which the NLB listener will listen | `number` | `80` | no |
| task_cpu | CPU units for the ECS task | `number` | `256` | no |
| task_memory | Memory for the ECS task in MiB | `number` | `512` | no |
| desired_count | Number of instances of the task to run | `number` | `1` | no |
| nlb_internal | Whether the NLB is internal | `bool` | `false` | no |
| enable_deletion_protection | Whether to enable deletion protection for the NLB | `bool` | `false` | no |
| assign_public_ip | Whether to assign public IP to the ECS tasks | `bool` | `false` | no |
| ingress_cidr_blocks | List of CIDR blocks to allow inbound traffic from | `list(string)` | `["0.0.0.0/0"]` | no |
| enable_container_insights | Whether to enable CloudWatch Container Insights | `bool` | `true` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | The ID of the ECS cluster |
| cluster_name | The name of the ECS cluster |
| service_name | The name of the ECS service |
| task_definition_arn | The ARN of the task definition |
| nlb_dns_name | The DNS name of the Network Load Balancer |
| nlb_arn | The ARN of the Network Load Balancer |
| target_group_arn | The ARN of the target group |
| security_group_id | The ID of the security group for ECS tasks |
| log_group_name | The name of the CloudWatch log group |

## License

MIT Licensed. See LICENSE for full details. 