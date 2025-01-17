resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_service" "app" {
  name           = var.mr_bot_service_name
  cluster        = aws_ecs_cluster.main.id
  desired_count  = 1
  launch_type    = "FARGATE"
  propagate_tags = "TASK_DEFINITION"
  network_configuration {
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
  }
}
