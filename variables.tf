variable "cluster_automode_role_policy_arn" {
    type = list(string)
    default = [ 
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSComputePolicy",
        "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
        "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
    ] 
}
variable "node_automode_role_policy_arn" {
    type = list(string)
    default = [ 
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
    ] 
}