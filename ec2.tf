resource "random_id" "suffix" {
  byte_length = 2
}

# Génération de la clé privée locale
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Sauvegarde de la clé privée localement
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/${var.instance_name}_id_rsa.pem"
}

# Création de la key pair AWS (une seule fois)
resource "aws_key_pair" "generated" {
  key_name   = "${var.instance_name}-key-${random_id.suffix.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh

  lifecycle {
    prevent_destroy = false
  }
}


############# Deploy VMs ######deploy_dev#################################################


 #####################################

 resource "aws_instance" "this" {
  for_each = local.instances

  ami           = data.aws_ami.ubuntu_2404.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated.key_name
  subnet_id     = each.value.subnet_id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 80
  }

  user_data = each.value.user_data

  metadata_options {
    http_tokens = "required"
  }

  monitoring = true

  tags = {
    Name        = "${var.instance_name}-${each.key}"
    Role        = each.value.role
    Executor    = lookup(each.value, "executor", null)
  }
}
