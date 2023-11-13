resource "tls_private_key" "kubernetes_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "kubernetes"
  public_key = tls_private_key.kubernetes_key.public_key_openssh
  tags       = local.tags
}


resource "aws_instance" "controller-instance" {
  count           = var.instance_count
  ami             = "ami-04b107e90218672e5"
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.ssh_key.key_name
  security_groups = ["${aws_security_group.kubernetes.id}"]
  subnet_id       = element(module.vpc.public_subnets, 0)
  private_ip      = "10.0.1.1${count.index}"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 50
  }
  tags = {
    Name = "controller-${count.index}"
  }
}


resource "aws_instance" "worker-instance" {
  count           = var.instance_count
  ami             = "ami-04b107e90218672e5"
  instance_type   = "t3.micro"
  key_name        = aws_key_pair.ssh_key.key_name
  security_groups = ["${aws_security_group.kubernetes.id}"]
  subnet_id       = element(module.vpc.public_subnets, 0)
  private_ip      = "10.0.1.2${count.index}"
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 50
  }
  tags = {
    Name = "worker-${count.index}"
  }
}
