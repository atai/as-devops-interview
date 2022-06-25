variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

resource "random_pet" "this" {}

locals {
  shared_obj_name = "as-devops-interview-${random_pet.this.id}"
}

variable "shared_cred_files" {
  description = "Credential files"
  type        = list(string)
  default     = ["./aws/credentials.txt"]
}

variable "resource_tags" {
  description = "Tags for resources"
  type        = map(string)
  default     = {
    owner   = "atai"
    project = "as-devops-interview"
  }
}