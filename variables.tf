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
