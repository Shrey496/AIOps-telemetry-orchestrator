variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string

}

variable "storage_bucket_name" {
  description = "The name of the GCS bucket for Mimir metrics"
  type        = string
}