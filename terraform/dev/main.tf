provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  # swap this for your bucket name
  bucket = "everlook-playground-terraform-state"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  # swap this for your dynamo lock table name
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# To successfully run this, you will have to comment out this terraform backend
# and create the above 2 resources (dynamodb + s3 bucket). Once those are created, you can...
# uncomment this backend & rerun `terraform init`.
terraform {
  backend "s3" {
    # swap this for your bucket name
    bucket         = "everlook-playground-terraform-state"
    key            = "msk/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

module "vpc" {
  source             = "../modules/vpc"

  region             = "us-east-1"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

module "ecs" {
  source     = "../modules/ecs-consumer"

  region              = "us-east-1"
  vpc_id              = module.vpc.vpc_id
  private_subnet_list = module.vpc.private_subnet_list

  depends_on          = [module.vpc]
}

module "msk" {
  source     = "../modules/msk"

  vpc_id                      = module.vpc.vpc_id
  private_subnet_list         = module.vpc.private_subnet_list
  container_security_group_id = module.ecs.container_security_group_id

  depends_on                  = [module.vpc]
}
