variable "task_family" {
  description = "The name for this ECS task."
  default = "resume_app_service"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket into which resumes will be stored."
}

variable "resume_name" {
  description = "The name of the resume to load."
  default = "latest"
}

variable "app_version" {
  description = "The version of our application to deploy."
}

variable "replica_count" {
  description = "The desired number of service replicas at any given time."
  default = 3
}

variable "load_balancer_name" {
  description = "The name to give our load balancer."
  default = "resume-app-lb"
}

variable "ecs_container_name" {
  description = "The name to give our containers."
  default = "resume_app"
}

variable "container_port" {
  description = "The port to expect our service to be running on."
  default = "4567"
}

variable "task_cpu_units" {
  description = "The number of CPU units to allocate to this task."
  default = "0.5"
}

variable "task_memory_units" {
  description = "The number of memory units to allocate to this task."
  default = "128"
}

variable "lb_subnet_a_cidr_block" {
  description = "The subnet CIDR block to use for the first availability zone."
}

variable "lb_subnet_b_cidr_block" {
  description = "The subnet CIDR block to use for the second availability zone."
}

variable "lb_vpc_cidr_block" {
  description = "The CIDR block to use for the VPC assigned to the load balancer for this service."
}
