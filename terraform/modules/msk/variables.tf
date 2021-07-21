variable private_subnet_list {
  type        = list
  description = "List of private subnets for ECS to use"
}

variable vpc_id {
  type        = string
  description = "VPC identifier"
}