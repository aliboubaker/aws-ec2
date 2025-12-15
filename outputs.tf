output "instance_public_ips" {
  description = "Public IPs of all EC2 instances"
  value       = aws_instance.ec2[*].public_ip
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key_pem.filename
}
