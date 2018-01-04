resource "aws_cloudwatch_log_group" "log" {
  name = "${var.logs_name}"
}
