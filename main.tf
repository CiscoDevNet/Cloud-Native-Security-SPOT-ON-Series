// Main //

// Deploy the Infrastructure
module "Infrastructure" {
  source = "./modules/infra"
  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
  region         = var.region
  ftd_user       = var.ftd_user
  ftd_pass       = var.ftd_pass
  env_name       = var.env_name
  env_id         = var.env_id
  aws_az1        = var.aws_az1
  aws_az2        = var.aws_az2
  key_name       = var.key_name
}

// Deploy Secure Cloud Analytics
module "Secure_Cloud_Analytics" {
  depends_on = [module.Infrastructure]
  source = "./modules/secure_cloud_analytics"
  sca_service_key = var.sca_service_key
}

// Deploy Secure Workload
module "Secure_Workload" {
  depends_on = [module.Infrastructure]
  source = "./modules/secure_workload"
  secure_workload_api_key    = var.secure_workload_api_key
  secure_workload_api_sec    = var.secure_workload_api_sec
  secure_workload_api_url    = var.secure_workload_api_url
  secure_workload_root_scope = var.secure_workload_root_scope
  eks_cluster_name           = module.Infrastructure.eks_cluster_name
  env_id                     = var.env_id
}

// Providers //

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.4.1"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.11.3"
    }
    tetration = {
      source = "CiscoDevNet/tetration"
      version = "0.1.0"
    }
  }
}
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region     =  var.region
}

provider "kubernetes" {
  host                   = module.Infrastructure.eks_cluster_api_endpoint
  cluster_ca_certificate = base64decode(module.Infrastructure.eks_cluster_ca)
  token                  = module.Infrastructure.eks_cluster_auth_token
  //load_config_file       = false
}

provider "kubectl" {
  host                   = module.Infrastructure.eks_cluster_api_endpoint
  cluster_ca_certificate = base64decode(module.Infrastructure.eks_cluster_ca)
  token                  = module.Infrastructure.eks_cluster_auth_token
  load_config_file       = false
}

provider "tetration" {
  api_key = var.secure_workload_api_key
  api_secret = var.secure_workload_api_sec
  api_url = var.secure_workload_api_url
  disable_tls_verification = true
}