# terraform-aws-backend
A Terraform module which enables you to create and manage your [Terraform AWS Backend resources](https://www.terraform.io/docs/backends/types/s3.html), _with terraform_ to achieve a best practice setup.

More info on the aws (s3/dynamo) backend supported by this module is found here:

https://www.terraform.io/docs/backends/types/s3.html

## Module options

Options and configuration for this module are exposed via terraform variables.


#### backend_bucket

This is the only variable which has no default but is required. You will need to define this value. 

#### dynamodb_lock_table_enabled

_Defaults to true._

- Set to false or 0 to prevent this module from creating the DynamoDB table to use for terraform state locking and consistency. More info on locking for aws/s3 backends: https://www.terraform.io/docs/backends/types/s3.html. More information about how terraform handles booleans here: https://www.terraform.io/docs/configuration/variables.html"
}

#### dynamodb_lock_table_stream_enabled

_Defaults to false._

Affects terraform-aws-backend module behavior. Set to false or 0 to disable DynamoDB Streams for the table. More info on DynamoDB streams: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html. More information about how terraform handles booleans here: https://www.terraform.io/docs/configuration/variables.html


#### dynamodb_lock_table_stream_view_type

_Defaults to `NEW_AND_OLD_IMAGES`_

Only applies if `dynamodb_lock_table_stream_enabled` is true.

#### dynamodb_lock_table_name

_Defaults to `terraform-lock`_

The name of your [terraform state locking](https://www.terraform.io/docs/state/locking.html) DynamoDB Table.

#### lock_table_read_capacity

_Defaults to 1 Read Capacity Unit._

More on DynamoDB Capacity Units: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CapacityUnitCalculations.html


#### lock_table_write_capacity
_Defaults to 1 Write Capacity Unit._

More on DynamoDB Capacity Units: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/CapacityUnitCalculations.html


### terraform-aws-backend terraform variables

See variables available for module configuration

https://github.com/samstav/terraform-aws-backend/blob/master/variables.tf


## Bootstrapping your project

A quick preface: For the purposes of this intro, we'll use a bucket named `terraform-state-bucket`, but you'll want to choose an appropriate name for the s3 bucket in which terraform will store your infrastructure state. Perhaps something like `terraform-state-<your_project-name>`, or, if you store all of your terraform state for all projects in a single bucket, `jacks-smirking-tf-state-bucket` with a `key` that defines a path/key name which is more project specific such as `states/projectX-terraform.tfstate`. 

#### describe your terraform backend resources

The following code 
```hcl
module "backend" {
  source = "github.com/samstav/terraform-aws-backend"
  backend_bucket = "terraform-state-bucket" 
}
```

The following commands will get you up and running:
```bash
# Step 1: Download modules
terraform get -update
# Step 2: Initialize your directory/project for use with terraform
# The use of -backend=false here is important: it avoids backend configuration
# on our first call to init since we havent created our backend resources yet
terraform init -backend=false
# Step 3: Create infrastructure plan for just the tf backend resources
# Target only the resources needed for our aws backend for terraform state/locking
terraform plan -out=backend.plan -target=module.backend
# Step 4: Apply the infrastructure plan
terraform apply backend.plan
# Step 5: Only after applying (building) the backend resources, write our terraform config
# Now we can write the terraform backend configuration into our project
# Instead of this command, you can write the terraform config block into any of your .tf files
echo 'terraform { backend "s3" {} }' > conf.tf
# Step 6: Reinitialize terraform to use your newly provisioned backend
terraform init -reconfigure \
    -backend-config="bucket=terraform-state-bucket" \
    -backend-config="key=states/terraform.tfstate" \
    -backend-config="dynamodb_table=terraform-lock"
```

Instead of using the `echo` command above in Step 5 (provided only for proof of concept), you can just write your terraform config into one of your \*.tf files. Otherwise you'll end up needing to provide the `-backend-config` [parameters partial configuration](https://www.terraform.io/docs/backends/config.html#partial-configuration) every single time you run `terraform init` (which might be often).

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket"
    key = "states/terraform.tfstate"
    dynamodb_table = "terraform-lock"
  }
}
```
