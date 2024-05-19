resource "aws_key_pair" "keypair" {
  key_name = "kp"

  public_key = file("ec2_kp.pub")
}