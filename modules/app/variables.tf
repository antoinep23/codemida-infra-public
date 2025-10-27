variable "ecr_repository_name" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "app_path" {
  type = string
}

variable "image_version" {
  type = string
}

variable "app_name" {
  type = string
}

variable "port" {
  type = number
}

variable "execution_role_arn" {
  type = string
}

variable "cluster_arn" {
  type = string
}

variable "is_public" {
  type    = bool
  default = true
}

variable "subnets" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lb_listener_arn" {
  type = string
}

variable "path_pattern" {
  type = string
}

variable "healthcheck_path" {
  type    = string
  default = "/*"
}

variable "envars" {
  type = list(map(any))
}

variable "secrets" {
  type      = list(map(any))
  sensitive = true
}

variable "lb_priority" {
  type = number
}

variable "ecs_cluster_name" {
  type = string
}

variable "task_max_capacity" {
  type    = number
  default = 3
}