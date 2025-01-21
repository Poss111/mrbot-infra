resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_service" "app" {
  name            = var.mr_bot_service_name
  cluster         = aws_ecs_cluster.main.id
  desired_count   = 1
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"
  task_definition = aws_ecs_task_definition.placeholder_task.arn

  network_configuration {
    subnets          = [aws_subnet.public.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_ecs_task_definition" "placeholder_task" {
  family                   = "placeholder-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB memory

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "placeholder-container"
      image     = "amazonlinux:latest"
      cpu       = 256
      memory    = 512
      essential = true
      command   = ["sleep", "200"]
    }
  ])
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
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "secretsmanager:*"
        ],
        Resource = "*",
      },
    ],
  })
}
