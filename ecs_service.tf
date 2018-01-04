resource "aws_ecs_service" "service" {
  name = "resume_app"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count = "${var.replica_count}"
  launch_type = "FARGATE"
  load_balancer {
    elb_name = "${aws_lb.lb.name}"
    container_name = "${var.ecs_container_name}"
    target_group_arn = "${aws_lb.lb.arn}"
    container_port = "${var.container_port}"
  }
  network_configuration {
    subnets = ["${aws_subnet.subnet_a.id}","${aws_subnet.subnet_b.id}"]
  }
}
