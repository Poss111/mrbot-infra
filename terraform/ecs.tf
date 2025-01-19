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
  deployment_controller {
    type = "EXTERNAL"
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "mr-bot-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "mr-bot-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "appconfig:StartConfigurationSession",
          "appconfig:GetLatestConfiguration"
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "mr-bot-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "mr-bot-ecs-task-execution-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:*"
        ],
        Resource = "*",
      },
    ],
  })
}
