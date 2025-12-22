```bash
> tf init && tf plan
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching ">= 4.0.0"...
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
var.name
  Base name for all IAM resources (role, policy, group, user)

  Enter a value: test

data.aws_caller_identity.current: Reading...
data.aws_caller_identity.current: Read complete after 0s [id=017845957019]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_group.this will be created
  + resource "aws_iam_group" "this" {
      + arn       = (known after apply)
      + id        = (known after apply)
      + name      = "test"
      + path      = "/"
      + unique_id = (known after apply)
    }

  # aws_iam_group_policy_attachment.assume_role will be created
  + resource "aws_iam_group_policy_attachment" "assume_role" {
      + group      = "test"
      + id         = (known after apply)
      + policy_arn = (known after apply)
    }

  # aws_iam_policy.assume_role will be created
  + resource "aws_iam_policy" "assume_role" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Allows assuming the test role"
      + id               = (known after apply)
      + name             = "test-assume-role"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags             = {
          + "Name" = "test-assume-role"
        }
      + tags_all         = {
          + "Name" = "test-assume-role"
        }
    }

  # aws_iam_role.this will be created
  + resource "aws_iam_role" "this" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Condition = {}
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::017845957019:root"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "test"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "Name" = "test"
        }
      + tags_all              = {
          + "Name" = "test"
        }
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_user.this will be created
  + resource "aws_iam_user" "this" {
      + arn           = (known after apply)
      + force_destroy = false
      + id            = (known after apply)
      + name          = "test"
      + path          = "/"
      + tags          = {
          + "Name" = "test"
        }
      + tags_all      = {
          + "Name" = "test"
        }
      + unique_id     = (known after apply)
    }

  # aws_iam_user_group_membership.this will be created
  + resource "aws_iam_user_group_membership" "this" {
      + groups = [
          + "test",
        ]
      + id     = (known after apply)
      + user   = "test"
    }

Plan: 6 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + group_arn   = (known after apply)
  + group_name  = "test"
  + policy_arn  = (known after apply)
  + policy_name = "test-assume-role"
  + role_arn    = (known after apply)
  + role_name   = "test"
  + user_arn    = (known after apply)
  + user_name   = "test"

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```