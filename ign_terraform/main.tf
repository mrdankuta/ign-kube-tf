resource "kubectl_manifest" "ignapp" {
  yaml_body = file("${path.module}/ign_k8s_deployment.yaml")
}
