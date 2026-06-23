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

  user_data = <<-EOF_SCRIPT
    #!/bin/bash
    apt-get update -y
    apt-get install -y apache2 php libapache2-mod-php unzip git
    systemctl enable apache2
    systemctl start apache2

    cat > /var/www/html/index.php <<'PHP'
    <?php
    echo "<h1>Student Feedback System - AWS Deployment</h1>";
    echo "<p>EC2 web server is running successfully.</p>";
    echo "<p>Deployed using Terraform.</p>";
    ?>
    PHP

    rm -f /var/www/html/index.html
  EOF_SCRIPT

  tags = {
    Name = "${var.project_name}-web-server"
  }
}
