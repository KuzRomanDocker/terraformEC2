#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
cat <<EOF > /var/www/html/index.html
<html>
<h2>Built by Power of Terraform <font color="red"> v0.15.3</font></h2><br>
Owner ${f_name} ${l_name} <br>

%{ for x in cars ~}
${f_name} want to buy ${x}<br>
%{ endfor ~}
<html>
EOF
sudo systemctl start httpd
sudo systemctl enable httpd
