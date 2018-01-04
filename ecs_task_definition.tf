data "template_file" "container_definition" {
  template = "${file("ecs_container_definition.json.tmpl")}"
  vars {
    s3_bucket_name  = "${var.s3_bucket_name}"
    app_version     = "${var.app_version}"
    resume_name     = "${var.resume_name}"
    container_name  = "${var.ecs_container_name}"
    container_port  = "${var.container_port}"
    logs_region     = "${data.aws_region.current.name}"
    logs_name       = "${var.logs_name}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.task_family}"
  cpu = "${var.task_cpu_units}"
  memory = "${var.task_memory_units}"
  requires_compatibilities = ["FARGATE"]
  container_definitions = "${data.template_file.container_definition.rendered}"
}
