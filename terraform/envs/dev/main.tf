module "s3_secure" {
  source = "../../modules/s3"

  name        = var.bucket_name
  environment = var.environment
  tags        = var.tags
  force_destroy = true
}
