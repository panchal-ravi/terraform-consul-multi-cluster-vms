terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  alias = "region1"
  region = "ap-southeast-1"
}

provider "aws" {
  alias = "region2"
  region = "ap-south-1"
}