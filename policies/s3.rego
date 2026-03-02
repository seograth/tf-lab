package terraform.s3

# Helpers
is_s3_bucket(rc) { rc.type == "aws_s3_bucket" }
is_s3_pab(rc)    { rc.type == "aws_s3_bucket_public_access_block" }
is_s3_ver(rc)    { rc.type == "aws_s3_bucket_versioning" }
is_s3_enc(rc)    { rc.type == "aws_s3_bucket_server_side_encryption_configuration" }

after(rc) = a {
  a := rc.change.after
  a != null
}

bucket_changes := [rc | rc := input.resource_changes[_]; is_s3_bucket(rc)]
pab_changes    := [rc | rc := input.resource_changes[_]; is_s3_pab(rc)]
ver_changes    := [rc | rc := input.resource_changes[_]; is_s3_ver(rc)]
enc_changes    := [rc | rc := input.resource_changes[_]; is_s3_enc(rc)]

# ----------------------------
# Required tags on S3 bucket
# ----------------------------
deny[msg] {
  rc := input.resource_changes[_]
  is_s3_bucket(rc)
  a := after(rc)
  not a.tags.owner
  msg := "S3 bucket must have tag: owner"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_bucket(rc)
  a := after(rc)
  not a.tags.environment
  msg := "S3 bucket must have tag: environment"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_bucket(rc)
  a := after(rc)
  not a.tags.managed_by
  msg := "S3 bucket must have tag: managed_by"
}

# ----------------------------
# Public access block required
# ----------------------------
deny[msg] {
  count(bucket_changes) > 0
  count(pab_changes) == 0
  msg := "S3 bucket requires aws_s3_bucket_public_access_block"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_pab(rc)
  a := after(rc)
  a.block_public_acls != true
  msg := "Public access block must set block_public_acls=true"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_pab(rc)
  a := after(rc)
  a.block_public_policy != true
  msg := "Public access block must set block_public_policy=true"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_pab(rc)
  a := after(rc)
  a.ignore_public_acls != true
  msg := "Public access block must set ignore_public_acls=true"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_pab(rc)
  a := after(rc)
  a.restrict_public_buckets != true
  msg := "Public access block must set restrict_public_buckets=true"
}

# ----------------------------
# Versioning required
# ----------------------------
deny[msg] {
  count(bucket_changes) > 0
  count(ver_changes) == 0
  msg := "S3 bucket requires aws_s3_bucket_versioning"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_ver(rc)
  a := after(rc)
  a.versioning_configuration.status != "Enabled"
  msg := "S3 bucket versioning must be Enabled"
}

# ----------------------------
# Encryption required (handles list shape)
# ----------------------------
deny[msg] {
  count(bucket_changes) > 0
  count(enc_changes) == 0
  msg := "S3 bucket requires aws_s3_bucket_server_side_encryption_configuration"
}

deny[msg] {
  rc := input.resource_changes[_]
  is_s3_enc(rc)
  a := after(rc)

  algos := [algo |
    rule := a.rule[_]
    def := rule.apply_server_side_encryption_by_default[_]
    algo := def.sse_algorithm
  ]

  # Fail if not exactly AES256
  algo := algos[_]
  algo != "AES256"
  msg := sprintf("S3 default encryption must be AES256 (got %v)", [algos])
}
