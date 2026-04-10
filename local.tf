locals {
  config = {
    dev = {
      ec2 = 2
      s3  = 1
      ddb = 1
    }
    staging = {
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

  current = local.config[terraform.workspace]
}