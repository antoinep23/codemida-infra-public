locals {
  apps = {
    ui = {
      ecr_repository_name = "codemida/ui"
      ecr_repository_url  = "<your_id>.dkr.ecr.eu-west-3.amazonaws.com"
      app_path            = "ui"
      app_name            = "ui"
      image_version       = "latest"
      port                = 3000
      is_public           = true
      task_max_capacity   = 3
      path_pattern        = "/*"
      lb_priority         = 20
      healthcheck_path    = "/"
      envars = [
        { }
      ]
      secrets = [{}]
    },
    api = {
      ecr_repository_name = "codemida/api"
      ecr_repository_url  = "<your_id>.dkr.ecr.eu-west-3.amazonaws.com"
      app_path            = "api"
      app_name            = "api"
      image_version       = "latest"
      port                = 8000
      is_public           = true
      task_max_capacity   = 3
      path_pattern        = "/api/v1/*"
      lb_priority         = 10
      healthcheck_path    = "/api/v1/healthcheck"
      envars              = [{}]
      secrets             = local.api_secrets_refs
    }
  }
}