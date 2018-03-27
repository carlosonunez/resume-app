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

resource "aws_route_table_association" "subnet_a" {
  subnet_id = "${aws_subnet.subnet_a.id}"
  route_table_id = "${data.aws_route_table.app_vpc.id}"
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id = "${aws_subnet.subnet_b.id}"
  route_table_id = "${data.aws_route_table.app_vpc.id}"
}
