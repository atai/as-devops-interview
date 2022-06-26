resource "random_pet" "this" {}

locals {
  region          = "eu-west-1"
  shared_obj_name = "as-devops-interview-${random_pet.this.id}"
}

variable "shared_cred_file" {
  description = "Credential file"
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