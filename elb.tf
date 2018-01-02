resource "aws_lb" "lb" {
  name = "${var.load_balancer_name}"
  internal = false
  load_balancer_type = "application"
  enable_deletion_protection = false
  subnets = ["${var.load_balancer_subnet_a}","${var.load_balancer_subnet_b}"]
}
