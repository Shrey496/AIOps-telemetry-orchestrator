resource "google_storage_bucket" "mimir_metrics" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true 

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}