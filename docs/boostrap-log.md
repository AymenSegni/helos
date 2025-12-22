# Boostartp Layer Outputs Logs

## Plan

```bash
> ./scripts/bootstrap.sh AymenSegni helos dev
[INFO] ============================================
[INFO]  Helos Bootstraping - DEV
[INFO] ============================================
[INFO] GitHub Org:  AymenSegni
[INFO] GitHub Repo: helos
[INFO] Environment: dev
[INFO]
[INFO] Checking AWS credentials...
[SUCCESS] AWS Account: ***************
[SUCCESS] AWS Region: eu-west-1
[INFO] Working directory: /Users/aymensegni/sides/bookish-adventure/bootstraping/deploy
[INFO] Using tfvars: dev.tfvars
[INFO] Initializing Terraform...
Initializing the backend...
Initializing modules...
- gha_oidc in ../modules/gha-oidc
- s3_tfstate in ../modules/s3-tfstate
Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 5.0.0"...
- Installing hashicorp/aws v6.27.0...
- Installed hashicorp/aws v6.27.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
[INFO] Planning Terraform changes...

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.gha_oidc.aws_iam_openid_connect_provider.github will be created
  + resource "aws_iam_openid_connect_provider" "github" {
      + arn             = (known after apply)
      + client_id_list  = [
          + "sts.amazonaws.com",
        ]
      + id              = (known after apply)
      + tags            = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "helos"
        }
      + tags_all        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "helos"
        }
      + thumbprint_list = [
          + "6938fd4d98bab03faadb97b34396831e3780aea1",
          + "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
        ]
      + url             = "https://token.actions.githubusercontent.com"
    }

  # module.gha_oidc.aws_iam_role.github_actions will be created
  + resource "aws_iam_role" "github_actions" {
      + arn                   = (known after apply)
      + assume_role_policy    = (known after apply)
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "helos-dev-github-actions"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "helos"
        }
      + tags_all              = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Project"     = "helos"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.s3_tfstate.aws_dynamodb_table.tflock will be created
  + resource "aws_dynamodb_table" "tflock" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "LockID"
      + id               = (known after apply)
      + name             = "helos-dev-tflock"
      + read_capacity    = (known after apply)
      + region           = "eu-west-1"
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags             = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "helos-dev-tflock"
          + "Project"     = "helos"
        }
      + tags_all         = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "helos-dev-tflock"
          + "Project"     = "helos"
        }
      + write_capacity   = (known after apply)

      + attribute {
          + name = "LockID"
          + type = "S"
        }

      + global_table_witness (known after apply)

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)

      + warm_throughput (known after apply)
    }

  # module.s3_tfstate.aws_s3_bucket.tfstate will be created
  + resource "aws_s3_bucket" "tfstate" {
      + acceleration_status         = (known after apply)
      + acl                         = (known after apply)
      + arn                         = (known after apply)
      + bucket                      = "helos-dev-tfstate"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_region               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = "eu-west-1"
      + request_payer               = (known after apply)
      + tags                        = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "helos-dev-tfstate"
          + "Project"     = "helos"
        }
      + tags_all                    = {
          + "Environment" = "dev"
          + "ManagedBy"   = "terraform"
          + "Name"        = "helos-dev-tfstate"
          + "Project"     = "helos"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + cors_rule (known after apply)

      + grant (known after apply)

      + lifecycle_rule (known after apply)

      + logging (known after apply)

      + object_lock_configuration (known after apply)

      + replication_configuration (known after apply)

      + server_side_encryption_configuration (known after apply)

      + versioning (known after apply)

      + website (known after apply)
    }

  # module.s3_tfstate.aws_s3_bucket_public_access_block.tfstate will be created
  + resource "aws_s3_bucket_public_access_block" "tfstate" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + id                      = (known after apply)
      + ignore_public_acls      = true
      + region                  = "eu-west-1"
      + restrict_public_buckets = true
    }

  # module.s3_tfstate.aws_s3_bucket_server_side_encryption_configuration.tfstate will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + region = "eu-west-1"

      + rule {
          + blocked_encryption_types = []
          + bucket_key_enabled       = true

          + apply_server_side_encryption_by_default {
              + sse_algorithm     = "aws:kms"
                # (1 unchanged attribute hidden)
            }
        }
    }

  # module.s3_tfstate.aws_s3_bucket_versioning.tfstate will be created
  + resource "aws_s3_bucket_versioning" "tfstate" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + region = "eu-west-1"

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

Plan: 7 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + gha_role_arn           = (known after apply)
  + tfstate_bucket_name    = (known after apply)
  + tfstate_dynamodb_table = "helos-dev-tflock"

────────────────────────────────────────────────────────────────────────────────────

Saved the plan to: tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "tfplan"

[WARN] Review the plan above.
Apply these changes? (yes/no):
```

## Apply

```bash
Apply these changes? (yes/no): yes
[INFO] Applying Terraform changes...
module.gha_oidc.aws_iam_openid_connect_provider.github: Creating...
module.s3_tfstate.aws_dynamodb_table.tflock: Creating...
module.s3_tfstate.aws_s3_bucket.tfstate: Creating...
module.gha_oidc.aws_iam_openid_connect_provider.github: Creation complete after 1s [id=arn:aws:iam::***************:oidc-provider/token.actions.githubusercontent.com]
module.gha_oidc.aws_iam_role.github_actions: Creating...
module.gha_oidc.aws_iam_role.github_actions: Creation complete after 0s [id=helos-dev-github-actions]
module.s3_tfstate.aws_s3_bucket.tfstate: Creation complete after 1s [id=helos-dev-tfstate]
module.s3_tfstate.aws_s3_bucket_public_access_block.tfstate: Creating...
module.s3_tfstate.aws_s3_bucket_versioning.tfstate: Creating...
module.s3_tfstate.aws_s3_bucket_server_side_encryption_configuration.tfstate: Creating...
module.s3_tfstate.aws_s3_bucket_public_access_block.tfstate: Creation complete after 1s [id=helos-dev-tfstate]
module.s3_tfstate.aws_s3_bucket_server_side_encryption_configuration.tfstate: Creation complete after 1s [id=helos-dev-tfstate]
module.s3_tfstate.aws_s3_bucket_versioning.tfstate: Creation complete after 2s [id=helos-dev-tfstate]
module.s3_tfstate.aws_dynamodb_table.tflock: Creation complete after 6s [id=helos-dev-tflock]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

gha_role_arn = "arn:aws:iam::***************:role/**************"
tfstate_bucket_name = "helos-dev-tfstate"
tfstate_dynamodb_table = "helos-dev-tflock"
[INFO]
[SUCCESS] ============================================
[SUCCESS]  Bootstraping Complete! (DEV)
[SUCCESS] ============================================
[INFO]
[INFO] Add this as a GitHub repository SECRET:

  AWS_OIDC_ROLE_ARN_DEV = arn:aws:iam::***************:role/**************

[INFO] S3 Backend configured:
  Bucket: helos-dev-tfstate
  DynamoDB Table: helos-dev-tflock

[INFO] Update backend-config in workflows to use:
  -backend-config="bucket=helos-dev-tfstate"
  -backend-config="dynamodb_table=helos-dev-tflock"

[SUCCESS] You can now run the GitHub Actions pipeline!
```
