variable "vpc_cidr" {
  type = string
}

variable "num_subnets" {
  type = number
}

variable "allowed_ips" {
  type = set(string)
}

variable "attach_cloudwatch_policy" {
  type    = bool
  default = false
}

variable "is_waf_enabled" {
  type    = bool
  default = false
}