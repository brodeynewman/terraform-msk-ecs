# Terraform MSK / ECS example

This example outlines how to provision a highly available MSK (Managed Kafka) cluster with Terraform.

## Why?

Kafka is an amazing tool, but for small to medium-sized teams, It's not realistic to manage a home-baked solution. This would involve countless hours of managing brokers on EC2, zookeeper clusters, and complex issues like multi-az clustering + failover. MSK takes care of this for you.

## Resources deployed

1. Multi-AZ MSK cluster including:

   - Security group + rules to allow inbound traffic from ECS + Bastion host

2. VPC including:
   - 2 Private Subnets
   - 2 Public Subnets
   - 2 Nat gateways
   - Internet Gateway
3. Bastion Host
4. ECS cluster including:
   - NodeJS image running KafkaJS consumer + producer code
   - ECS service + ECR repo setup
   - Security groups

## Architecture

todo
