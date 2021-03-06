# EB
data "archive_file" "app" {
  type = "zip"
  source_dir = "../src"
  output_path = "./app-v1.zip"
}

data "aws_iam_role" "this" {
  name = "aws-elasticbeanstalk-service-role"
}

resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.this.id
  key    = "beanstalk/app-v1.zip"
  source = "app-v1.zip"
  tags   = local.resource_tags
}

resource "aws_elastic_beanstalk_application" "this" {
  name = local.shared_obj_name
  tags = local.resource_tags
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

  tags = local.resource_tags
}

resource "aws_elastic_beanstalk_configuration_template" "this" {
  name                = local.shared_obj_name
  application         = aws_elastic_beanstalk_application.this.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.15 running Python 3.8"
}