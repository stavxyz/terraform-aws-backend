## terraform-aws-backend fresh start example

In this example, we assume no existing backend resources. That is,
we will create our s3 bucket(s) and dynamodb lock table from
scratch without doing any `terraform import`s.

To run this example:

```
terraform init -backend=false
terraform plan -out=backend.plan -target=module.backend -var 'backend_bucket=tf-backend-aws-example'
terraform apply backend.plan
echo 'terraform { backend "s3" {} }' > conf.tf
terraform init -reconfigure -backend-config=conf.tfvars

# Now 'show' should show your terraform backend resource attributes
terraform show
```
