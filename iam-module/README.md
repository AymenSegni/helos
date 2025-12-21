# IAM Module

Simple Terraform module that creates four IAM resources with consistent naming:

1. **IAM Role** - Assumable by identities in the same AWS account
2. **IAM Policy** - Allows `sts:AssumeRole` on the created role
3. **IAM Group** - With the policy attached
4. **IAM User** - Added to the group

## Usage

```hcl
module "iam_resources" {
  source = "./terraform/iam-module"

  name = "bitcoin-operator"
  path = "/"

  tags = {
    Environment = "dev"
    Project     = "helos"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Base name for all IAM resources | `string` | n/a | yes |
| path | IAM path for all resources | `string` | `"/"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| role_arn | ARN of the created IAM role |
| role_name | Name of the created IAM role |
| policy_arn | ARN of the assume role policy |
| policy_name | Name of the assume role policy |
| group_arn | ARN of the created IAM group |
| group_name | Name of the created IAM group |
| user_arn | ARN of the created IAM user |
| user_name | Name of the created IAM user |

## Example

```bash
cd terraform/iam-module/examples
terraform init
terraform plan
terraform apply
terraform destroy
```
