# tf_backend_aws
terraform backend resources managed by terraform.

Bootstrap your project whose resources will be managed by terraform:

```hcl
module "backend" {
  source = "github.com/samstav/tf_backend_aws"
  backend_bucket = "terraform-state-bucket" 
}
```

The following commands will get you up and running:
```bash
terraform get -update
# Avoid backend configuration on our first call to init since we havent created our resources yet
terraform init -backend=false
# Target only the resources needed for our aws backend for terraform state/locking
terraform plan -out=backend.plan -target=module.backend
terraform apply backend.plan
# *now* we can write the terraform backend configuration into our project
echo 'terraform { backend "s3" {} }' > conf.tf
# re-initialize and you're good to go
terraform init -reconfigure -backend-config=conf.tfvars
```
