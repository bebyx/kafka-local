resource "kubernetes_namespace" "kafka" {
  metadata {
    name = "kafka"
  }
}

resource "kubernetes_namespace" "producer" {
  metadata {
    name = "producer"
  }
}

resource "kubernetes_namespace" "consumer" {
  metadata {
    name = "consumer"
  }
}
