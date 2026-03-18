terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  
  # Remote State Backend
  backend "gcs" {
    bucket = "sh-tf-state-328814" #This bucket was manually created on GCP using Cloud shell
    prefix = "terraform/state/dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Provision the GKE Cluster
module "gke_cluster" {
  source       = "../../modules/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
}

# 2. Provision the Object Storage
module "mimir_storage" {
  source      = "../../modules/storage"
  project_id  = var.project_id
  region      = var.region
  bucket_name = var.storage_bucket_name
}

# 3. Workload Identity IAM Binding
resource "google_service_account" "mimir_sa" {
  account_id   = "mimir-storage-sa"
  display_name = "Mimir Storage Service Account"
}

resource "google_storage_bucket_iam_member" "mimir_storage_admin" {
  bucket = module.mimir_storage.bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.mimir_sa.email}"
}

resource "google_service_account_iam_member" "mimir_workload_identity" {
  service_account_id = google_service_account.mimir_sa.name
  role               = "roles/iam.workloadIdentityUser"
  # Maps the GCP Service Account to the Kubernetes Service Account
  member             = "serviceAccount:${var.project_id}.svc.id.goog[monitoring/mimir-sa]"
}