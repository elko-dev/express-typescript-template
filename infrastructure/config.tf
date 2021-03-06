data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "test-org-compoze"
    workspaces = {
      # defaulting to production only vpc
      name = "test-org-compoze-vpc-${local.infra_environment}"
    }
  }
}

data "terraform_remote_state" "route-53" {
  backend = "remote"

  config = {
    organization = "test-org-compoze"
    workspaces = {
      # It is worth noting - route53 will always be production
      name = "test-org-compoze-route53-${local.infra_environment}"
    }
  }
}

data "aws_vpc" "selected" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "secrets"
  region = "us-east-1"
}

locals {
  domain = "compozesandbox.com"
  # Removing trailing dot from domain - just to be sure :)
  domain_name        = trimsuffix(local.domain, ".")
  name               = "${var.name}-${var.environment}"
  environment        = var.environment
  infra_environment  = "prod" # default infrastructure environment is production. route53 will generally always be production (could eventually remove environment enitrely) but for  remaining environments we will default to prod for MVP
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnets_id = data.terraform_remote_state.vpc.outputs.private_subnets
  public_subnets_id  = data.terraform_remote_state.vpc.outputs.public_subnets
  //  bastion_sg_id        = data.terraform_remote_state.vpc.outputs.bastion_sg_id
  domain_prefix = var.production ? "" : "${var.environment}."
  dns_name      = "api.${local.domain_prefix}${local.domain}"
  platform      = "compoze"

  input_queue_name = local.name
  common_tags = {
    Name        = local.name
    Application = var.name
    Environment = var.environment
    Terraform   = "cloud"
  }
}

//data "aws_iam_role" "ecs-auto-scaling" {
//  name = "AWSServiceRoleForApplicationAutoScaling_ECSService"
//}
