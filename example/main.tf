provider "aws" {
  region = "us-west-2"
}

# VPC and Networking
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ecs-fargate-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "example"
    Project     = "ecs-fargate-demo"
  }
}

# ECS Fargate Module with Blue/Green Deployment
module "ecs_fargate" {
  source = "../"

  # Basic Configuration
  cluster_name = "example-cluster"
  service_name = "example-service"
  task_family  = "example-task"

  # Container Configuration
  container_name  = "example-container"
  container_image = "nginx:latest"  # Example using nginx
  container_port  = 80

  # Task Configuration
  task_cpu    = 256
  task_memory = 512
  desired_count = 2

  # Network Configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  assign_public_ip = false

  # Load Balancer Configuration
  internal_alb = true
  alb_port    = 80
  alb_ingress_cidr_blocks = ["10.0.0.0/16"]  # Restrict to VPC CIDR

  # Container Configuration
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = "production"
    },
    {
      name  = "APP_VERSION"
      value = "1.0.0"
    }
  ]

  # Container Secrets (Example)
  container_secrets = [
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:ssm:us-west-2:123456789012:parameter/db-password"
    }
  ]

  # Health Check Configuration
  health_check_path = "/health"
  health_check_interval = 30
  health_check_timeout = 5
  health_check_healthy_threshold = 3
  health_check_unhealthy_threshold = 3

  # Logging Configuration
  enable_container_insights = true
  log_retention_days       = 7

  # Tags
  tags = {
    Environment = "example"
    Project     = "ecs-fargate-demo"
    ManagedBy   = "terraform"
    Deployment  = "blue-green"
  }
}

# Outputs
output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_fargate.cluster_id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_fargate.service_name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs_fargate.alb_dns_name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.ecs_fargate.log_group_name
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = module.ecs_fargate.codedeploy_app_name
}

output "codedeploy_deployment_group_name" {
  description = "Name of the CodeDeploy deployment group"
  value       = module.ecs_fargate.codedeploy_deployment_group_name
}

output "blue_target_group_arn" {
  description = "ARN of the blue target group"
  value       = module.ecs_fargate.blue_target_group_arn
}

# Example of how to use the outputs in a deployment script
output "deployment_instructions" {
  description = "Instructions for deploying the application"
  value = <<EOF
To deploy a new version:

1. Update the container image in your CI/CD pipeline
2. Create an appspec.yml file:
   version: 0.0
   Resources:
     - TargetService:
         Type: AWS::ECS::Service
         Properties:
           TaskDefinition: <TASK_DEFINITION>
           LoadBalancerInfo:
             ContainerName: "example-container"
             ContainerPort: 80
           PlatformVersion: "LATEST"

3. Use AWS CLI to create a deployment:
   aws deploy create-deployment \
     --application-name ${module.ecs_fargate.codedeploy_app_name} \
     --deployment-group-name ${module.ecs_fargate.codedeploy_deployment_group_name} \
     --revision '{"revisionType": "AppSpecContent", "appSpecContent": {"content": "..."}}'

4. Monitor the deployment:
   aws deploy get-deployment --deployment-id <DEPLOYMENT_ID>
EOF
} 