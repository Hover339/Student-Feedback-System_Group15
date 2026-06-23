# Random suffix to make the S3 bucket name globally unique
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  s3_bucket_name = "${var.project_name}-secure-storage-${random_id.bucket_suffix.hex}"
}

# AWS Academy blocks some S3 Object Lock read permissions used by the native
# aws_s3_bucket Terraform resource. This terraform_data resource uses AWS CLI
# commands to create and secure the bucket without needing the null provider.
resource "terraform_data" "s3_secure_storage" {
  input = {
    bucket_name = local.s3_bucket_name
    region      = var.aws_region
  }

  provisioner "local-exec" {
    command = <<EOT
set -e

aws s3api head-bucket --bucket ${local.s3_bucket_name} >/dev/null 2>&1 || \
aws s3api create-bucket \
  --bucket ${local.s3_bucket_name} \
  --region ${var.aws_region}

aws s3api put-public-access-block \
  --bucket ${local.s3_bucket_name} \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-encryption \
  --bucket ${local.s3_bucket_name} \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-bucket-versioning \
  --bucket ${local.s3_bucket_name} \
  --versioning-configuration Status=Enabled
EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rb s3://${self.input.bucket_name} --force || true"
  }
}
