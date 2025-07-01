# Create an IAM Policy for to restrict permissions needed for the Load Balancer Controller for operations
resource "aws_iam_policy" "alb_iam_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./modules/alb/iam_policy.json") # Loaded from an external file (iam_policy.json).
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
    "${format("kubernetes.io/cluster/%s-%s", var.org_name, var.environment)}" = "owned"
  }

}

# Attach the IAM Policy document to the above IAM Policy: Defines who/what can assume the IAM role.
data "aws_iam_policy_document" "aws-load-balancer-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"] # The service account aws-load-balancer-controller in the kube-system namespace can assume this role.
    }

    principals {
      identifiers = [var.oidc_arn]
      type        = "Federated"
    }
  }

}

# Create an IAM Service Role for Load Balancer: This is the IAM role that the controller will use, based on the above trust policy.
resource "aws_iam_role" "aws-load-balancer-controller" {
  assume_role_policy = data.aws_iam_policy_document.aws-load-balancer-controller.json
  name               = "aws-load-balancer-controller"

}

# IAM Policy attachment for the Service Role
resource "aws_iam_role_policy_attachment" "aws-load-balancer-controller" {
  role       = aws_iam_role.aws-load-balancer-controller.name
  policy_arn = aws_iam_policy.alb_iam_policy.arn

}



# Deploy AWS Load Balancer Controller via Helm
resource "helm_release" "lbc" {
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  version         = var.awslb_version
  repository      = "https://aws.github.io/eks-charts"
  namespace       = "kube-system"
  cleanup_on_fail = true

  set = [
    {
      name  = "clusterName"
      value = var.clustername
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },

    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws-load-balancer-controller.arn
    }



  ]

  
}

