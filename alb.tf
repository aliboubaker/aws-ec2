#ACM CONFIGURATION
#Creates ACM issues certificate and requests validation via DNS(Route53)
resource "aws_acm_certificate" "jenkins-lb-https" {
  domain_name       = join(".", ["*", data.aws_route53_zone.dns.name])
  validation_method = "DNS"
  tags = {
    Name = "Jenkins-ACM"
  }

}
#DNS VALIDATION RECORD FOR ACM CERTIFICATE
# Wait for ACM validation
resource "aws_acm_certificate_validation" "jenkins-lb-https" {
  certificate_arn         = aws_acm_certificate.jenkins-lb-https.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


####ACM CONFIG END


resource "aws_lb" "application-lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "Jenkins-LB"
  }
}

resource "aws_lb_target_group" "app-lb-tg" {
  for_each        = local.instance_ports
  name        = "app-lb-tg-${each.key}"
  port        = each.value
  target_type = "instance"
  vpc_id      = aws_vpc.vpc_master.id
  protocol    = "HTTP"
  health_check {
    enabled  = true
    interval = 10
    path     = "/"
    port     = each.value
    protocol = "HTTP"
    matcher  = "200-299"
  }
  tags = {
    Name = "jenkins-target-group"
  }
}

resource "aws_lb_listener" "jenkins-listener" {
  #for_each        = local.instance_ports
  load_balancer_arn = aws_lb.application-lb.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.jenkins-lb-https.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "404"
      content_type = "text/plain"
      message_body = "Not found"
   }
 }
}

resource "aws_lb_listener" "jenkins-listener-http" {
  load_balancer_arn = aws_lb.application-lb.arn
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

resource "aws_lb_listener_rule" "jenkins-routing" {
  for_each = local.instance_ports

  listener_arn = aws_lb_listener.jenkins-listener.arn
  priority     = 100 + index(keys(local.instance_ports), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb-tg[each.key].arn
  }

  condition {
    host_header {
      values = ["${each.key}.${data.aws_route53_zone.dns.name}"]
    }
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attach" {
  for_each        = local.instance_ports
  target_group_arn = aws_lb_target_group.app-lb-tg[each.key].arn
  target_id        = aws_instance.this[each.key].id
  port             = each.value
}