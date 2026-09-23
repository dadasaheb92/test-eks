module "vpc" {
  source = "git::https://github.com/Rushi-Technologies/vpc.git"
  name = "rds-vpc"
  cidr_block = "10.0.0.0/16"
  tags = {
    "owner" = "DevOps"
    "env" = "dev"
    "project" = "hrpl-mcd"
  }
  public_subnet_cidrs = ["10.0.0.0/20"]
  private_subnet_cidrs = ["10.0.32.0/20"]
  public_subnets_azs = data.aws_availability_zones.az.names[*]
  private_subnets_azs = data.aws_availability_zones.az.names[*]
  public_subnet_tags = {"kubernetes.io/role/elb":"1"}
  private_subnet_tags = {"kubernetes.io/role/internal-elb":"1"}
  create_nat_gateway = true
}

#Role with assume policy for eks cluster and nodes
resource "aws_iam_role" "cluterrole" {
    name = "eks-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
}
resource "aws_iam_role" "noderole" {
    name = "eks-node-role"
    assume_role_policy = data.aws_iam_policy_document.node_group_assume_role_policy.json
}

#Required AWS managed policy attachment to role for eks clsuter and node 
resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  for_each = toset(var.cluster_automode_role_policy_arn)
  role       = aws_iam_role.cluterrole.name
  policy_arn = each.value
}
resource "aws_iam_role_policy_attachment" "node_policy_attachment" {
  for_each = toset(var.node_automode_role_policy_arn)
  role       = aws_iam_role.noderole.name
  policy_arn = each.value
}

#Create EKS cluster with Automode
resource "aws_eks_cluster" "main" {
  name = "production-eks-clsuter"
  role_arn = aws_iam_role.cluterrole.arn
  version  = "1.36"

  #Enable both EKS Access Entries API and ConfigMap for cluster authentication.
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }
  
  #Enable Automode compute (Aws will provide node automatically after deployment done)
  compute_config {
    enabled       = true
    node_pools    = ["general-purpose","system"]
    node_role_arn = aws_iam_role.noderole.arn
  }
  #Enable Auto mode networking and loadbalancing.
  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }
  #Enable Auto mode storage.
  storage_config {
    block_storage {
      enabled = true
    }
  }
  #Enable VPC configiration for EKS automode cluster.
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = flatten(["module.vpc.public_subnet_ids","module.vpc.private_subnet_ids"])
  }
  
  enabled_cluster_log_types = [ "api","audit","authenticator","controllerManager","scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy_attachment,
    aws_iam_role_policy_attachment.node_policy_attachment 
  ]
}