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

variable "terraform_s3_state_bucket" {
  description = "The S3 bucket to store remote state into."
}

variable "terraform_s3_state_key" {
  description = "The key to locate the state with inside of the bucket above."
}
