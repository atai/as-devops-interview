# EB
resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.this.id
  key    = "beanstalk/app-v1.zip"
  source = "app-v1.zip"
  tags   = var.resource_tags
}

resource "aws_elastic_beanstalk_application" "this" {
  name = local.shared_obj_name
  tags = var.resource_tags
}

resource "aws_elastic_beanstalk_application_version" "this" {
  name        = local.shared_obj_name
  application = aws_elastic_beanstalk_application.this.name
  bucket      = aws_s3_bucket.this.id
  key         = aws_s3_object.default.id
}

resource "aws_elastic_beanstalk_environment" "this" {
  application         = aws_elastic_beanstalk_application.this.id
  name                = local.shared_obj_name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.15 running Python 3.8"
  setting {
    name      = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    name      = "RetentionInDays"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value     = "7"
  }
  setting {
    name      = "XRayEnabled"
    namespace = "aws:elasticbeanstalk:xray"
    value     = "true"
  }
  setting {
    name      = "WSGIPath"
    namespace = "aws:elasticbeanstalk:container:python"
    value     = "application"
  }

  tags = var.resource_tags
}