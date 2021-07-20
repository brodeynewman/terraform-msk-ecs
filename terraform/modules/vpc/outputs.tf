output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_list" {
  value = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
}