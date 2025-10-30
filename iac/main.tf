terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
  required_version = ">= 1.0"
}

provider "kubernetes" {
  # Uses KUBE_CONFIG passed from Minikube in GitHub Actions
  config_path = pathexpand("~/.kube/config")
}

# -----------------------------
# Kubernetes Deployment
# -----------------------------
resource "kubernetes_deployment" "silvester_deploy" {
  metadata {
    name = "silvester-deploy"
    labels = {
      app = "silvester-web"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "silvester-web"
      }
    }

    template {
      metadata {
        labels = {
          app = "silvester-web"
        }
      }

      spec {
        container {
          name  = "silvester-container"
          image = var.docker_image
          image_pull_policy = "Always"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# -----------------------------
# Kubernetes Service
# -----------------------------
resource "kubernetes_service" "silvester_service" {
  metadata {
    name = "silvester-service"
  }

  spec {
    type = "NodePort"

    selector = {
      app = "silvester-web"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30007
    }
  }
}

# -----------------------------
# Variable for Docker image
# -----------------------------
variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
}
