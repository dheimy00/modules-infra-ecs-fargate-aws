output "cluster_id" {
  description = "The ID of the ECS cluster"
  value       = local.cluster_id
}

output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = local.cluster_name
}

output "service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.service.name
}

output "task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.task.arn
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.nlb.dns_name
}

output "nlb_arn" {
  description = "The ARN of the Network Load Balancer"
  value       = aws_lb.nlb.arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.tg.arn
}

output "security_group_id" {
  description = "The ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

output "ecs_tasks_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}
