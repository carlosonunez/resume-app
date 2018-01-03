resource "aws_lb" "lb" {
  name = "${var.load_balancer_name}"
  internal = false
  load_balancer_type = "application"
  enable_deletion_protection = false
  subnets = ["${var.lb_subnet_a_cidr_block}","${var.lb_subnet_b_cidr_block}"]
}
