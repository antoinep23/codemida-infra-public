variable "api_secrets" {
  type = map(string)
}

locals {
  api_secrets = var.api_secrets

  api_secrets_refs = [
    for name, secret in aws_secretsmanager_secret.api :
    {
      name      = name
      valueFrom = secret.arn
    }
  ]
}

resource "aws_secretsmanager_secret" "api" {
  for_each                = var.api_secrets
  name                    = "codemida/api/v1/${each.key}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "api_value" {
  for_each      = var.api_secrets
  secret_id     = aws_secretsmanager_secret.api[each.key].id
  secret_string = each.value
}