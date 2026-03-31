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
  version          = "18.5.14"
  namespace        = kubernetes_namespace.producer.metadata[0].name
  create_namespace = false

  set {
    name  = "auth.postgresPassword"
    value = "postgres"
  }

  set {
    name  = "auth.username"
    value = "app"
  }

  set {
    name  = "auth.password"
    value = "app"
  }

  set {
    name  = "auth.database"
    value = "appdb"
  }
}

resource "helm_release" "minio" {
  name             = "minio"
  repository       = "${var.docker_oci_url}/cloudpirates/"
  chart            = "minio"
  version          = "0.11.0"
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