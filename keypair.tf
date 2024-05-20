resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits = 4096
  
}


resource "aws_key_pair" "keypair" {
  key_name = "ec2_kp"

  public_key = tls_private_key.keypair.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.keypair.key_name}.pem"
  content = tls_private_key.keypair.private_key_pem
}

