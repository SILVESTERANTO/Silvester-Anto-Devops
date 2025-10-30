terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create Namespace
resource "kubernetes_namespace" "silvester" {
  metadata {
    name = "silvester-ns"
  }
}

# Deploy Application
resource "kubernetes_deployment" "silvester_app" {
  metadata {
    name      = "silvester-deploy"
    namespace = kubernetes_namespace.silvester.metadata[0].name
    labels = {
      app = "silvester-website"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "silvester-website"
      }
    }

    template {
      metadata {
        labels = {
          app = "silvester-website"
        }
      }

      spec {
        container {
          name  = "silvester-website"
          image = "silvesteranto/silvester-website:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Service
resource "kubernetes_service" "silvester_service" {
  metadata {
    name      = "silvester-service"
    namespace = kubernetes_namespace.silvester.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.silvester_app.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30007
    }

    type = "NodePort"
  }
}
