resource "random_pet" "this" {}

locals {
  region          = "eu-west-1"
  shared_obj_name = "as-devops-interview-${random_pet.this.id}"
  resource_tags   = {
    owner   = "atai"
    project = "as-devops-interview"
  }
  shared_cred_file = ["./aws/credentials.txt"]
}