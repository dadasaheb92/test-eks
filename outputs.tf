output "eks_cluster_arn" {
    value = aws_eks_cluster.main.arn
}
output "eks_cluster_endpoint" {
    value = aws_eks_cluster.main.endpoint
}
output "eks_cluster_name" {
    value = aws_eks_cluster.main.name
}