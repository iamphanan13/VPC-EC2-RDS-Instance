terraform {
  required_providers {
    // Required AWS version 4.16
    aws = {
        source = "hashicorp/aws"
        version = "4.16"
    }
  }
  // Required Terraform version 1.2
  required_version = ">= 1.2.0"
}


provider "aws" {
  region = var.aws_region
}






