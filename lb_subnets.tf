resource "aws_subnet" "subnet_a" {
  availability_zone = "${format("%s%s",data.aws_region.current.name,"a")}"
  cidr_block = "${format("%s.65.0/24",join(".",slice(split(".",data.aws_vpc.current.cidr_block),0,2)))}"
  map_public_ip_on_launch = false
  vpc_id = "${data.aws_vpc.current.id}"
}

resource "aws_subnet" "subnet_b" {
  availability_zone = "${format("%s%s",data.aws_region.current.name,"b")}"
  cidr_block = "${format("%s.66.0/24",join(".",slice(split(".",data.aws_vpc.current.cidr_block),0,2)))}"
  map_public_ip_on_launch = false
  vpc_id = "${data.aws_vpc.current.id}"
}
