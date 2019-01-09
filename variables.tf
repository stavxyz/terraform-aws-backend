variable "backend_bucket" {}

variable "dynamodb_lock_table_enabled" {
  default = 1
  description = "Affects terraform-aws-backend module behavior. Set to false or 0 to prevent this module from creating the DynamoDB table to use for terraform state locking and consistency. More info on locking for aws/s3 backends: https://www.terraform.io/docs/backends/types/s3.html. More information about how terraform handles booleans here: https://www.terraform.io/docs/configuration/variables.html"
}

variable "dynamodb_lock_table_stream_enabled" {
  default = 0
  description = "Affects terraform-aws-backend module behavior. Set to false or 0 to disable DynamoDB Streams for the table. More info on DynamoDB streams: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html. More information about how terraform handles booleans here: https://www.terraform.io/docs/configuration/variables.html"
}

variable "dynamodb_lock_table_stream_view_type" {
  default = "NEW_AND_OLD_IMAGES"
}

variable "dynamodb_lock_table_name" {
  default = "terraform-lock"
}

variable "lock_table_read_capacity" {
  default = 1
}

variable "lock_table_write_capacity" {
  default = 1
}

variable "kms_key_id" {
  # Default to absent/blank to use the default aws/s3 aws kms master key
  default = ""
  description = "The AWS KMS master key ID used for the SSE-KMS encryption on the tf state s3 bucket. If the kms_key_id is specified, the bucket default encryption key management method will be set to aws-kms. If the kms_key_id is not specified (the default), then the default encryption key management method will be set to aes-256 (also known as aws-s3 key management). The default aws/s3 AWS KMS master key is used if this element is absent (the default)."
}
