terraform {
  backend "s3" {
    bucket = "bucket-for-diplom"                // Bucket where to SAVE Terraform State
    key    = "dos-07/tfstate/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                        // Region where bucket created
  }
}
