output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_b.id
}

output "private_db_subnet_a_id" {
  value = aws_subnet.private_db_a.id
}

output "private_db_subnet_b_id" {
  value = aws_subnet.private_db_b.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "web_security_group_id" {
  value = aws_security_group.web_sg.id
}

output "db_security_group_id" {
  value = aws_security_group.db_sg.id
}

output "s3_bucket_name" {
  value = local.s3_bucket_name
}

output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.web.public_dns
}

output "ec2_website_url" {
  value = "http://${aws_instance.web.public_dns}"
}

output "cloudtrail_name" {
  value = aws_cloudtrail.main.name
}

output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.ec2_high_cpu.alarm_name
}
