resource "aws_ecs_service" "service" {
  name = "resume_app-${var.environment}"
  depends_on = ["aws_iam_role_policy.execution_role_policy", "aws_lb.lb"]
  cluster = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count = "${var.replica_count}"
  launch_type = "FARGATE"
  load_balancer {
    container_name = "${var.ecs_container_name}"
    target_group_arn = "${aws_lb_target_group.target_group.arn}"
    container_port = "${var.container_port}"
  }
  network_configuration {
    subnets = ["${aws_subnet.subnet_a.id}","${aws_subnet.subnet_b.id}"]
    security_groups = ["${aws_security_group.ecs_inbound.id}"]
    assign_public_ip = true
  }
}
