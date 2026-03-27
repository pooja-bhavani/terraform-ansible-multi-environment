# EKS Module v21.x — Key changes from v19.x:
#   - cluster_name  → name
#   - cluster_addons → addons
#   - aws-auth ConfigMap removed — use access_entries instead
#   - EKS Pod Identity replaces IRSA
#   - Default AMI type is now AL2023 (not AL2)
#   - AWS provider v6.0+ required

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Cluster configuration (renamed from cluster_name in v19)
  name                   = local.name
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Grant the cluster creator admin permissions (replaces aws-auth ConfigMap)
  enable_cluster_creator_admin_permissions = true

  # EKS Add-ons (renamed from cluster_addons in v19)
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true # Deploy before node groups to avoid networking issues
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true # New in v21: replaces IRSA for pod-level IAM
    }
  }

  # Networking
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # Managed Node Group defaults
  eks_managed_node_group_defaults = {
    instance_types                        = ["t2.medium"]
    attach_cluster_primary_security_group = true
  }

  # Managed Node Groups
  eks_managed_node_groups = {
    bankapp-ng = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT" # SPOT = cheaper, ON_DEMAND = more reliable

      tags = {
        ExtraTag = "MyCluster"
      }
    }
  }

  tags = local.tags
}
