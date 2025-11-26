output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "frontend_public_ip" {
  description = "Frontend EC2 public IP"
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "Backend EC2 private IP"
  value       = aws_instance.backend.private_ip
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name for static content"
  value       = aws_s3_bucket.static_content.bucket
} 