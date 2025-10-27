# root main.tf

module "infra" {
  source                   = "./modules/infra"
  vpc_cidr                 = "10.0.0.0/16"
  num_subnets              = 2
  allowed_ips              = ["0.0.0.0/0"]
  attach_cloudwatch_policy = true
  is_waf_enabled           = true
}

module "app" {
  source                = "./modules/app"
  for_each              = local.apps
  ecr_repository_name   = each.value.ecr_repository_name
  ecr_repository_url    = each.value.ecr_repository_url
  app_path              = each.value.app_path
  image_version         = each.value.image_version
  app_name              = each.value.app_name
  port                  = each.value.port
  is_public             = each.value.is_public
  path_pattern          = each.value.path_pattern
  lb_priority           = each.value.lb_priority
  envars                = each.value.envars
  secrets               = each.value.secrets
  healthcheck_path      = each.value.healthcheck_path
  task_max_capacity     = each.value.task_max_capacity
  execution_role_arn    = module.infra.execution_role_arn
  cluster_arn           = module.infra.cluster_arn
  subnets               = module.infra.public_subnets
  app_security_group_id = module.infra.app_security_group_id
  vpc_id                = module.infra.vpc_id
  lb_listener_arn       = module.infra.lb_listener_arn
  ecs_cluster_name      = module.infra.ecs_cluster_name
}

output "alb_dns_name" {
  value = "https://${module.infra.alb_dns_name}"
}