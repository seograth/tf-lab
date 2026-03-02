variable "name" {
  description = "S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket (deletes all objects/versions). Use true only for ephemeral envs."
  type        = bool
  default     = false
}
