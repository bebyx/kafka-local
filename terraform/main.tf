resource "helm_release" "strimzi" {
  name             = "strimzi"
  repository       = "https://strimzi.io/charts/"
  chart            = "strimzi-kafka-operator"
  version          = "0.51.0"
  namespace        = kubernetes_namespace.kafka.metadata[0].name
  create_namespace = false
}

resource "helm_release" "postgres" {
  name             = "postgres"
  repository       = "${var.docker_oci_url}/bitnamicharts"
  chart            = "postgresql"
  version          = var.postgres_version
  namespace        = kubernetes_namespace.producer.metadata[0].name
  create_namespace = false

  # YAML encoded style due to init script with multi-line string
  values = [
    yamlencode({
      auth = {
        postgresPassword = "postgres"
        username         = "app"
        password         = "app"
        database         = "appdb"
      }

      primary = {
        initdb = {
          scripts = {
            "init.sql" = <<-EOT
              CREATE TABLE test (
                id SERIAL PRIMARY KEY,
                value TEXT
              );
            EOT
          }
        }
      }
    })
  ]
}

resource "helm_release" "minio" {
  name             = "minio"
  repository       = "${var.docker_oci_url}/cloudpirates/"
  chart            = "minio"
  version          = var.minio_version
  namespace        = kubernetes_namespace.consumer.metadata[0].name
  create_namespace = false

  set {
    name  = "auth.rootUser"
    value = "minio"
  }

  set {
    name  = "auth.rootPassword"
    value = "minio12345"
  }

  set {
    name  = "defaultBuckets"
    value = "kafka-sink"
  }
}