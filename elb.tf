resource "aws_lb" "lb" {
  name = "${var.load_balancer_name}"
  internal = false
  load_balancer_type = "application"
  enable_deletion_protection = false
  subnets = ["${aws_subnet.subnet_a.id}","${aws_subnet.subnet_b.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name = "resume-app-lb-tg"
  depends_on = ["aws_lb.lb"]
  port = 4567
  protocol = "HTTP"
  vpc_id = "${var.load_balancer_vpc}"
  health_check {
    port = 4567
    protocol = "HTTP"
  }
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  depends_on = ["aws_lb.lb"]
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    type = "forward"
  }
  load_balancer_arn = "${aws_lb.lb.arn}"
}
