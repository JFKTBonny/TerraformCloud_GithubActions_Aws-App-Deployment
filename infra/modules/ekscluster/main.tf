# locals {
#   safe_clustername = substr(
#     lower(replace(var.clustername, "[^a-z0-9-]", "-")),
#     0,
#     25
#   )
# }

# Create an EKS Cluster with Nodegroups in Private subnet
module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  version           = "18.26.0"
  cluster_name      = var.clustername
  cluster_version   = var.eks_version
  subnet_ids        = var.private_subnets
  vpc_id            = var.vpc_id
  enable_irsa       = true
  iam_role_name     = "${var.clustername}-eks-role"

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  node_security_group_additional_rules = {
    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allows secure webhook traffic (port 9443) between control plane and nodes (used by ALB Controller)"
    }
    egress_all = {
      description      = "Allows all outbound internet traffic from nodes"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type          = "AL2_x86_64"
    disk_size         = 50
    ebs_optimized     = true
    enable_monitoring = true
    instance_types    = var.instance_types
    capacity_type     = "ON_DEMAND"
    desired_size      = 1
    max_size          = 3
    min_size          = 1

    update_config = {
      max_unavailable_percentage = 50
    }
  }

  eks_managed_node_groups = {
    system = {
      name            = "system"
      use_name_prefix = true
      tags = {
        Name              = "system"
        Environment       = var.environment
        terraform-managed = "true"
        "${format("kubernetes.io/cluster/%s-%s", var.org_name, var.environment)}" = "owned"
      }
    }
    app = {
      name            = "app"
      use_name_prefix = true
      tags = {
        Name              = "app"
        Environment       = var.environment
        terraform-managed = "true"
       
      }
    }
  }

  tags = {
    Name              = var.clustername
    Environment       = var.environment
    terraform-managed = "true"
    "${format("kubernetes.io/cluster/%s-%s", var.org_name, var.environment)}" = "owned"
  }
}
