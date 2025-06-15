# Create an EKS Cluster with Nodegroups in Private subnet
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.0"
  cluster_name    = var.clustername
  cluster_version = var.eks_version
  subnet_ids      = var.private_subnets # Cluster deployed into private subnets.
  vpc_id          = var.vpc_id
  enable_irsa     = true        # Uses IAM Roles for Service Accounts (IRSA) – best practice for secure pod permissions.

  cluster_addons = { 
    coredns = {
      resolve_conflicts = "OVERWRITE" # Adds CoreDNS (for internal DNS) and OVERWRITE: ensures existing configurations are updated.
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE" # VPC CNI (for pod networking) and OVERWRITE: ensures existing configurations are updated.
    }
  }

  # Extend node-to-node security group rules
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

  # Default Settings applicable to all node groups
  eks_managed_node_group_defaults = {
    ami_type          = "AL2_x86_64" # Nodes use Amazon Linux 2.
    disk_size         = 50           # Nodes use 50GB disks.
    ebs_optimized     = true         # EBS optimized enabled.
    enable_monitoring = true         # Monitoring  enabled.
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
      name            = "system" # Typically used for core workloads (monitoring, DNS, etc.).
      use_name_prefix = true

      tags = {
        Name              = "system"
        Environment       = var.environment
        terraform-managed = "true"
      }
    },
    app = {
      name            = "app" # Used for your business applications.
      use_name_prefix = true

      tags = {
        Name              = "app"
        Environment       = var.environment
        terraform-managed = "true"
      }
    }
  }
  # Good tagging practice for visibility and cost tracking.
  tags = {
    Name              = var.clustername
    Environment       = var.environment
    terraform-managed = "true"
  }

}