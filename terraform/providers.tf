provider "kubernetes" {
  config_path    = pathexpand("~/.kube/config")
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path    = pathexpand("~/.kube/config")
    config_context = "minikube"
  }

  registry {
    url = "${var.docker_oci_url}/bitnamicharts"
    username = var.docker_username
    password = var.docker_token
  }

  registry {
    url = "${var.docker_oci_url}/cloudpirates"
    username = var.docker_username
    password = var.docker_token
  }
}
