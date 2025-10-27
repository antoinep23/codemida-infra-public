output "execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "public_subnets" {
  value = [for subnet in aws_subnet.this : subnet.id]
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "lb_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}