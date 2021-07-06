
output "my_instance_id_webserver" {
  value = aws_instance.WebServer.id
}

output "my_instance_id_appserver" {
  value = aws_instance.APPServer.id
}

output "aws_security_group" {
  value = aws_security_group.my_servers.id
}
