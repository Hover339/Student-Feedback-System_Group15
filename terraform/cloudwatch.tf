resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name          = "${var.project_name}-ec2-high-cpu"
  alarm_description   = "Alarm when EC2 CPU utilization is higher than 70 percent"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  treat_missing_data = "notBreaching"

  tags = {
    Name        = "${var.project_name}-ec2-high-cpu"
    Environment = "assignment-demo"
  }
}
