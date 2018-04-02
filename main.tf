/*
 * Module: tf_backend_aws
 *
 * Bootstrap your terraform backend on AWS.
 *
 * This module configures resources for state locking for terraform >= 0.9.0
 * https://github.com/hashicorp/terraform/blob/master/CHANGELOG.md#090-march-15-2017
 *
 * This template creates and/or manages the following resources
 *   - An S3 Bucket for storing terraform state
 *   - An S3 Bucket for storing logs from the state bucket
 *   - A DynamoDB table to be used for state locking and consistency
 *
 * The DynamoDB state locking table is optional: to disable,
 * set the 'dynamodb_lock_table_enabled' variable to false.
 * For more info on how terraform handles boolean variables:
 *   - https://www.terraform.io/docs/configuration/variables.html
 *
 * If using an existing S3 Bucket, perform a terraform import on your bucket
 * into your tf_backend_aws module instance:
 *
 * $ terraform import module.backend.aws_s3_bucket.tf_backend_bucket <your_s3_bucket_name>
 *
 * where the 'backend' portion is the name you choose:
 *
 * module "backend" {
 *   source = "github.com/samstav/tf_backend_aws"
 * }
 *
 */

terraform {
  required_version = ">= 0.9.0"
}

data "aws_caller_identity" "current" {}

resource "aws_dynamodb_table" "tf_backend_state_lock_table" {
  count = "${var.dynamodb_lock_table_enabled ? 1 : 0}"
  name           = "${var.dynamodb_lock_table_name}"
  read_capacity  = "${var.lock_table_read_capacity}"
  write_capacity = "${var.lock_table_write_capacity}"
  hash_key       = "LockID"
  stream_enabled = "${var.dynamodb_lock_table_stream_enabled}"
  stream_view_type = "${var.dynamodb_lock_table_stream_enabled ? var.dynamodb_lock_table_stream_view_type : ""}"

  attribute {
    name = "LockID"
    type = "S"
  }
  tags {
    Description = "Terraform state locking table for account ${data.aws_caller_identity.current.account_id}."
    ManagedByTerraform = "true"
    TerraformModule = "tf_backend_aws"
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket" "tf_backend_bucket" {
  bucket = "${var.backend_bucket}"
  acl = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = "${aws_s3_bucket.tf_backend_logs_bucket.id}"
    target_prefix = "log/"
  }
  tags {
    Description = "Terraform S3 Backend bucket which stores the terraform state for account ${data.aws_caller_identity.current.account_id}."
    ManagedByTerraform = "true"
    TerraformModule = "tf_backend_aws"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "tf_backend_logs_bucket" {
  bucket = "${var.backend_bucket}-logs"
  acl = "log-delivery-write"
  versioning {
    enabled = true
  }
  tags {
    Purpose = "Logging bucket for ${var.backend_bucket}"
    ManagedByTerraform = "true"
    TerraformModule = "tf_backend_aws"
  }
  lifecycle {
    prevent_destroy = true
  }
}

