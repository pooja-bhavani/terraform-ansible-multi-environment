output "ec2_public_ips" {
  value = aws_instance.my_instance[*].public_ip
}

output "ec2_ids" {
  value = aws_instance.my_instance[*].id
}

output "s3_bucket_names" {
  value = aws_s3_bucket.terrabucket[*].bucket
}

output "dynamodb_table_names" {
  value = aws_dynamodb_table.my_app_table[*].name
}