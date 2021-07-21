variable private_subnet_list {
  type        = list
  description = "List of private subnets for ECS to use"
}

variable vpc_id {
  type        = string
  description = "VPC identifier"
}

variable container_security_group_id {
  type        = string
  description = "Container security group ID"
}

variable bastion_security_group_id {
  type        = string
  description = "Bastion host security group ID"
}