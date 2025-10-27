terraform {
  backend "s3" {
    bucket       = "codemida-terraform-state"
    key          = "terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}