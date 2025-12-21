output "role_arn" {
  description = "ARN of the bitcoind IAM role"
  value       = aws_iam_role.bitcoind.arn
}

output "role_name" {
  description = "Name of the bitcoind IAM role"
  value       = aws_iam_role.bitcoind.name
}
