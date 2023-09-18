resource "kubectl_manifest" "ignapp" {
  yaml_body = file("${path.module}/ign_k8s_deployment.yaml")
}

# run this first: `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update`

resource "helm_release" "kube_prom" {
  name       = "kube-prometheus-stack"
  chart      = "prometheus-community/kube-prometheus-stack"

}