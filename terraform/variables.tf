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

variable "minio_version" {
  description = "Minio Helm chart version"
  type        = string
  default     = "0.11.0"
}

variable "postgres_version" {
  description = "PostgreSQL Helm chart version"
  type        = string
  default     = "18.5.14"
}

variable "strimzi_version" {
  description = "Strimzi Helm chart version"
  type        = string
  default     = "0.51.0"
}