variable "docker_oci_url" {
  description = "Default Docker OCI URL for pulling charts"
  type        = string
  default     = "oci://registry-1.docker.io"
}


variable "docker_username" {
  description = "DockerHub username to authorize for pulling OCI charts"
  type        = string
  sensitive   = true
}

variable "docker_token" {
  description = "DockerHub PAT to authorize for pulling OCI charts"
  type        = string
  sensitive   = true
}
