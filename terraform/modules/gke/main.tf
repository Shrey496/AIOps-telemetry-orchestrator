#Cretae the GKE Control Plane
resource "google_container_cluster" "primary" {
    name    = var.cluster_name
    location    = "${var.region}-a" #Zonal cluster to save on costs

    #Removing default node pool to manage worker nodes independently
    remove_default_node_pool    = true
    initial_node_count  = 1

    network = "default"
    subnetwork = "default"

    #Private node pool
    private_cluster_config {
    enable_private_nodes    = true  
    enable_private_endpoint = false #Keeps API public so Cloud Shell can access it
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All Networks"
    }
  }

    #Enable Workload Identity 
    workload_identity_config {
        workload_pool = "${var.project_id}.svc.id.goog"
    }

    deletion_protection = false
}

resource "google_container_node_pool" "spot_nodes" {
  name       = "spot-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 2
  location    = "${var.region}-a"

  node_config {
    spot  = true # Enables Spot VMs for cost reduction
    machine_type = "e2-standard-4" # 4 vCPUs, 16GB RAM 

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA" # Required for Workload Identity on nodes
    }
  }
}