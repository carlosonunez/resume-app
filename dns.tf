data "aws_route53_zone" "requested_zone" {
  name = "${var.dns_zone_name}"
  private_zone = false
}

resource "aws_route53_record" "main" {
  depends_on = ["aws_lb.lb"]
  zone_id = "${data.aws_route53_zone.requested_zone.zone_id}"
  name = "${var.dns_record_name}"
  type = "A"
  alias {
    name = "${aws_lb.lb.dns_name}"
    zone_id = "${aws_lb.lb.zone_id}"
    evaluate_target_health = true
  }
}
