variable "backend_bucket" {
}


provider "aws" {
      region  = "us-west-2"
}

module "backend" {
  /*
   * Since this example lives in the module repository,
   * we use a relative path '../', but typically we would use
   * the github url, like so:
   *
   * source = "github.com/samstav/terraform-aws-backend"
  */

  source         = "../../"
  backend_bucket = var.backend_bucket
}

#
# Just to demonstrate...
#

output "s3_backend_bucket_name" {
  value = module.backend.s3_backend_bucket_name
}

output "dynamodb_lock_table_name" {
  value = module.backend.dynamodb_lock_table_name
}

output "dynamodb_lock_table_arn" {
  value = module.backend.dynamodb_lock_table_arn
}

output "dynamodb_lock_stream_arn" {
  value = module.backend.dynamodb_lock_stream_arn
}

output "dynamodb_lock_stream_label" {
  value = module.backend.dynamodb_lock_stream_label
}
