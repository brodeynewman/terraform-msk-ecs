data "aws_iam_role" "ecr" {
  name = "AWSServiceRoleForECRReplication"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = "msk"
  attributes = ["private"]
  delimiter  = "-"
}

module "ecr" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=master"
  namespace              = module.label.namespace
  name                   = module.label.name
  image_tag_mutability   = "MUTABLE"
  principals_full_access = [data.aws_iam_role.ecr.arn]
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_cloudwatch_log_group" "consumer" {
  name = "msk-consumer"
}

resource "aws_ecs_task_definition" "consumer" {
  family                   = "consumer"
  network_mode             = var.network_mode
  requires_compatibilities = [var.ecs_launch_type]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions    = <<DEFINITION
[
  {
    "cpu": ${var.task_cpu},
    "secrets": [
      {
        "name": "KAFKA_BROKERS",
        "valueFrom": "arn:aws:secretsmanager:us-east-1:164831777623:secret:test-secrets-649uGj:KAFKA_BROKERS::"
      }
    ],
    "environment": [
      {
        "name": "BROKER_LIST",
        "value": "${var.broker_list}"
      }
    ],
    "essential": true,
    "image": "${module.ecr.repository_url}:latest",
    "memory": ${var.task_memory},
    "name": "msk-consumer",
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.consumer.id}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "default" {
  name = module.label.id
}

resource "aws_security_group" "ecs_service" {
  name        = "ECS service sec group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ECS consumer security group"
  }
}

resource "aws_ecs_service" "consumer" {
  name                               = "msk-consumer"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.consumer.arn
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent 
  desired_count                      = var.desired_count
  launch_type                        = var.ecs_launch_type

  network_configuration {
    assign_public_ip = false

    subnets          = var.private_subnet_list
    security_groups  = [aws_security_group.ecs_service.id]
  }
}