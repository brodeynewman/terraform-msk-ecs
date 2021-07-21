resource "aws_security_group" "msk" {
  vpc_id = var.vpc_id
}

resource "aws_cloudwatch_log_group" "msk" {
  name = "msk_broker_logs"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "everlook-msk-broker-logs-bucket"
  acl    = "private"
}

resource "aws_msk_cluster" "example" {
  cluster_name           = "msk-example"
  kafka_version          = "2.8.0"
  number_of_broker_nodes = 4

  broker_node_group_info {
    # Making this super small for cost purposes...
    instance_type   = "kafka.t3.small"
    ebs_volume_size = 10

    # private subnets
    client_subnets = var.private_subnet_list
    security_groups = [aws_security_group.msk.id]
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  tags = {
    name = "MSK engine"
  }
}