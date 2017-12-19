resource "aws_ecs_service" "service" {
  name = "resume_app"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count = "${var.replica_count}"
}
