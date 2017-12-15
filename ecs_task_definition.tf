data "template_file" "container_definition" {
  template = "${file("ecs_container_definition.json.tmpl")}"
  vars {
    s3_bucket_name  = "${var.s3_bucket_name}"
    app_version     = "${var.app_version}"
    resume_name     = "${var.resume_name}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family = "${var.task_family}"
  container_definitions = "${data.template_file.container_definition.rendered}"
}
