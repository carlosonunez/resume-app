resource "aws_lb" "lb" {
  name = "${var.load_balancer_name}"
  internal = false
  load_balancer_type = "application"
  enable_deletion_protection = false
  subnets = ["${aws_subnet.subnet_a.cidr_block}","${aws_subnet.subnet_b.cidr_block}"]
}
