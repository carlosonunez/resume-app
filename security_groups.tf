resource "aws_security_group" "lb_inbound" {
  name = "resume_app_${var.environment}_lb_inbound_sg"
  description = "Allow inbound access to load balancer from the Internet."
  vpc_id = "${aws_vpc.app.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    version = "${var.app_version}"
  }
}

resource "aws_security_group" "ecs_inbound" {
  name = "resume_app_${var.environment}_ecs_inbound_sg"
  description = "Allow inbound access to ECS containers from load balancer."
  vpc_id = "${aws_vpc.app.id}"
  ingress {
    from_port = 4567 
    to_port = 4567
    protocol = "tcp"
    security_groups = ["${aws_security_group.lb_inbound.id}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    version = "${var.app_version}"
  }
}
