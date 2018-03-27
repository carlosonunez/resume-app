resource "aws_vpc" "app" {
  cidr_block = "${var.lb_vpc_cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "app" {
  vpc_id = "${aws_vpc.app.id}"
}

data "aws_route_table" "app_vpc" {
  vpc_id = "${aws_vpc.app.id}"
}

resource "aws_route" "app_outbound_internet" {
  route_table_id = "${data.aws_route_table.app_vpc.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.app.id}"
}
