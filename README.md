# Fannaq infrastructure

We highly recommend storing the Terraform code for each of your environments (e.g. stage, prod, qa) in separate sets of templates (and therefore, separate .tfstate files). This is important so that your separate environments are actually isolated from each other while making changes. Otherwise, while messing around with some code in staging, it's too easy to blow up something in prod too. See Terraform, VPC, and why you want a tfstate file per env for a colorful discussion of why.
