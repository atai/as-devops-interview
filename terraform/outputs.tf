output "app_url" {
  description = "Deployed application URL"
  value = "http://${aws_elastic_beanstalk_environment.this.endpoint_url}"
}