## tf_backend_aws example

To run this example:

```
terraform get -update
terraform init -backend=false
terraform plan -out=backend.plan -target=module.backend -var 'backend_bucket=tf-backend-aws-example'
terraform apply backend.plan
echo 'terraform { backend "s3" {} }' > conf.tf
terraform init -reconfigure -backend-config=conf.tfvars

# Now 'show' should show your terraform backend resource attributes
terraform show
```
