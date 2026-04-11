locals {
  config = {
    dev = {
      ec2 = 2
      s3  = 1
      ddb = 1
    }
    stag = {
      ec2 = 3
      s3  = 1
      ddb = 1
    }
    prod = {
      ec2 = 4
      s3  = 2
      ddb = 2
    }
  }

  current = lookup(local.config, terraform.workspace, local.config["dev"])

  key_names = {
    dev     = "terra-key-dev"
    staging = "terra-key-staging"
    prod    = "terra-key-prod"
  }
}