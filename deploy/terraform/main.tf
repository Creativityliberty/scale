terraform {
  required_version = ">= 1.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.40"
    }
  }
}

provider "scaleway" {
  region     = var.scw_region
  zone       = var.scw_zone
  project_id = var.scw_project_id
}

# Cluster Kubernetes (Kapsule)
resource "scaleway_k8s_cluster" "main" {
  name        = "mon-saas-ia-cluster"
  version     = "1.30.0"
  cni         = "cilium"
  description = "Cluster Kubernetes pour le SaaS IA multi-agents"
  
  delete_additional_resources = false
  tags                        = ["saas", "ai", "production"]
}

resource "scaleway_k8s_pool" "workers" {
  cluster_id = scaleway_k8s_cluster.main.id
  name       = "workers"
  node_type  = var.node_type
  size       = var.node_count
  
  autoscaling = true
  autohealing = true
  min_size    = var.min_nodes
  max_size    = var.max_nodes
  
  tags = ["worker", "autoscale"]
}

# Base PostgreSQL (RDB)
resource "scaleway_rdb_instance" "db" {
  name           = "mon-saas-ia-db"
  node_type      = var.db_node_type
  engine         = "PostgreSQL-15"
  is_ha_cluster  = var.db_ha_enabled
  disable_backup = false
  
  user_name = "app"
  password  = var.db_password
  
  tags = ["postgresql", "saas"]
}

resource "scaleway_rdb_database" "app" {
  instance_id = scaleway_rdb_instance.db.id
  name        = "app"
}

# Container Registry
resource "scaleway_registry_namespace" "main" {
  name        = var.scw_namespace
  description = "Images Docker du SaaS IA"
  is_public   = false
}

# Outputs
output "cluster_id" {
  value = scaleway_k8s_cluster.main.id
}

output "kubeconfig" {
  value     = scaleway_k8s_cluster.main.kubeconfig[0].config_file
  sensitive = true
}

output "registry_endpoint" {
  value = scaleway_registry_namespace.main.endpoint
}

output "db_endpoint" {
  value = scaleway_rdb_instance.db.endpoint_ip
}

output "db_port" {
  value = scaleway_rdb_instance.db.endpoint_port
}

output "database_url" {
  value     = "postgresql+psycopg2://${scaleway_rdb_instance.db.user_name}:${var.db_password}@${scaleway_rdb_instance.db.endpoint_ip}:${scaleway_rdb_instance.db.endpoint_port}/${scaleway_rdb_database.app.name}"
  sensitive = true
}
