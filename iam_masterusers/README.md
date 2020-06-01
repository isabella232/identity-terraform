# `iam_masteruser`

This Terraform module can be used to create one or more IAM users.
Group memberships are assigned per-user for simpler user management.

By default, an IAM policy called ***ManageYourAccount*** will also be created,
which is attached to all users in `user_map`. It allows each user
basic access to configure their own account, i.e. updating their own
password, adding an MFA device, etc., and sets an explicit **Deny** on
numerous actions -- *including* `sts:AssumeRole` -- if the user does
not have an MFA device configured.

The creation of this IAM policy can be disabled by setting the variable
`allow_self_management` to **false**.

## Example

```hcl
module "our_cool_master_users" {
  source = "github.com/18F/identity-terraform//iam_masterusers?ref=master"
  
  user_map = {
    'fred.flinstone' = ['development'],
    'barny.rubble' = ['devops'],
    'space.ghost' = ['devops', 'host'],
  }
}
```

## Variables

`user_map` - Map with user name as key and a list of group memberships as the value.
`allow_self_management` - Whether or not to create the 'ManageYourAccount' IAM policy
and attach it to all users in var.user_map in this account.
