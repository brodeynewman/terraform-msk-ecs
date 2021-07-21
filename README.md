# Terraform MSK / ECS example

This example outlines how to provision a highly available MSK cluster with Terraform.

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
