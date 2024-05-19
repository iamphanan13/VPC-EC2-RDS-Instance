output "public_ip" {
  description = "The public IP address of the web server"

  value = aws_eip.eip[0].public_ip
  // Grabbing it from Elastic IP
  depends_on = [ aws_eip.eip ]
}

output "public_dns" {
  value = aws_eip.eip[0].public_dns 
  depends_on = [ aws_eip.eip ]
}

output "db_endpoint" {
  description = "The endpoint of the database"
  value = aws_db_instance.database.address
}

output "db_port" {
  description = "The port of database"
  value = aws_db_instance.database.port
}