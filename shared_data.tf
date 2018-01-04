data "aws_region" "current" {
  current = true
}

data "aws_vpc" "current" {
  id = "${var.load_balancer_vpc}"
}

