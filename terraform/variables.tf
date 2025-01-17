variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_route_cidr" {
  description = "The CIDR block for the public route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "container_image" {
  description = "The image of the container"
  type        = string
}

variable "task_cpu" {
  description = "The amount of CPU to reserve for the container"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "The amount of memory to reserve for the container"
  type        = string
  default     = "512"
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "The port the host listens on"
  type        = number
  default     = 80
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "main-cluster"
}

variable "ecs_service_name" {
  description = "The name of the ECS service"
  type        = string
  default     = "main-service"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Service     = "Mr. Bot"
  }
}
