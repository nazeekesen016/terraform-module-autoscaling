resource "aws_launch_template" "template" {
  name          = var.template_name
  image_id      = var.image-id
  instance_type = var.instance-type
  user_data     = base64encode("#!/bin/bash \nsudo su \napt install apache2 -y \nsystemctl enable apache2 -y \nsystemctl start apache2 -y \necho \"Hello, World!\" > /var/www/html/index.html")
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.value.id]

  }
}

resource "aws_security_group" "value" {
  name   = var.sg-name
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  dynamic "egress" {
    for_each = [0]
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

#   tags = {
#     Name  = "SecurityGroup"
#     Owner = "Nazik"
#   }
}

resource "aws_autoscaling_group" "asg" {
  name              = var.asg-name
  max_size          = 4
  min_size          = 2
  desired_capacity  = 3
  force_delete      = true
  target_group_arns = [aws_lb_target_group.test1.id]
  launch_template {
    id = aws_launch_template.template.id
  }
  vpc_zone_identifier = var.subnets
  depends_on = [
    aws_launch_template.template
  ]
}

resource "aws_lb" "test" {
  name               = var.lb-name
  internal           = false
  load_balancer_type = var.lb-type
  security_groups    = [aws_security_group.value.id]
  subnets            = var.subnets
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test1.arn
  }

}
resource "aws_lb_target_group" "test1" {
  name     = var.tg-name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}