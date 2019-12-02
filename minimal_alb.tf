resource "aws_alb" "mylb" {
  # Normal ALB content, options removed for BLOG
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.myapp.id]
}

# Basic https lisener to demo HTTPS certiciate
resource "aws_alb_listener" "mylb_https" {
  load_balancer_arn = aws_alb.mylb.arn
  certificate_arn   = aws_acm_certificate.myapp.arn
  port              = "443"
  protocol          = "HTTPS"
  # Default action, and other paramters removed for BLOG
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<html><body><h1>Hello World!</h1><p>This would usually be to a target group of web servers.. but this is just a demo to returning a fixed response\n\n</p></body></html>"
      status_code  = "200"
    }
  }
}

# Always good practice to redirect http to https
resource "aws_alb_listener" "mylb_http" {
  load_balancer_arn = aws_alb.mylb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Open Security Group for demo
resource "aws_security_group" "myapp" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}