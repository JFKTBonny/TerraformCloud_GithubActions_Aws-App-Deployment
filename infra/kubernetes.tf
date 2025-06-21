
# host: API endpoint of the EKS cluster.
# Kubernetes provider to execute kubernetes workloads: to apply Kubernetes resources (Deployment, Service, etc.)
# telling Terraform how to authenticate and talk to your EKS cluster
# exec block: Tells Terraform how to get a token for the cluster via AWS CLI.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"  
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_id
    ]
  }
}

# Helm provider to apply helm charts: to install Helm charts (nginx-ingress, prometheus, etc.)
# exec block: Tells Terraform how to get a token for the cluster via AWS CLI.
# cluster_ca_certificate: Base64-decoded certificate to verify the API server.
# host: API endpoint of the EKS cluster.
# Helm needs to talk to Kubernetes → so you provide the same connection/authentication details inside the nested kubernetes {} block
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint  
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) 
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"    
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_id
      ]
    }
  }
}