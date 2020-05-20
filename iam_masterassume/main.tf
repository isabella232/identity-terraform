# -- Variables --

variable "account_numbers" {
  description = "List of AWS account numbers where this policy can access the specified Assumable role"
  type = list(any)
}

variable "role_types" {
  description = "Type/name of the Assumable role(s). Should correspond to actual role name(s) in the account(s) listed."
  type = list(any)
}

variable "account_type" {
  description = "Type/name that the listed account(s) fall under (e.g. prod, dev, etc.)"
}

# -- Resources --

data "aws_iam_policy_document" "role_type_policy" {
  for_each = toset(var.role_types)

  statement {
    sid    = join("", [title(var.account_type), "Assume", title(each.key)])
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = formatlist("arn:aws:iam::%s:role/${each.key}",var.account_numbers)
  }
}

resource "aws_iam_policy" "role_type_policy" {
  for_each = toset(var.role_types)

  name        = join("", [title(var.account_type), "Assume", title(each.key)])
  path        = "/"
  description = "Policy to allow user to assume ${each.key} role in ${var.account_type}."
  policy      = data.aws_iam_policy_document.role_type_policy[each.key].json
}

output "role_arns" {
  value = zipmap(
      sort(var.role_types),
      sort(values(aws_iam_policy.role_type_policy)[*]["arn"]))
}