# output "instance_public_ips" {
#   description = "Public IPs of all EC2 instances"
#   #value       = aws_instance.ec2[*].public_ip
#   value = {
#     for instance in aws_instance.ec2 :
#     instance.id => instance.public_ip
#   }
# }

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.private_key_pem.filename
}

# IP publiques
output "public_ips" {
  description = "Adresses IP publiques des instances"
  value       = { for k, inst in aws_instance.this : k => inst.public_ip }
}

