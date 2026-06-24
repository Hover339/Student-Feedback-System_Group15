data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "web_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.module}/student-feedback-key.pub")
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.web_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo "EC2 created by Terraform" > /tmp/terraform-boot.txt
  EOF

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/student-feedback-key")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/user_data_student_feedback.sh"
    destination = "/tmp/user_data_student_feedback.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/user_data_student_feedback.sh",
      "sudo bash /tmp/user_data_student_feedback.sh"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/frontend_polish.sh"
    destination = "/tmp/frontend_polish.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend_polish.sh",
      "sudo bash /tmp/frontend_polish.sh"
    ]
  }

  tags = {
    Name = "${var.project_name}-web-server"
  }
}