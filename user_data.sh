#!/bin/bash
sudo yum update -y
sudo yum install git -y
sudo amazon-linux-extras install docker -y
sudo yum install mysql -y
sudo service docker start
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
git clone https://github.com/MoreiraGabriel95/Atividade-AWS-Docker
cd Atividade-AWS-Docker
docker-compose -f docker-compose.yml up -d

sudo mkdir /efs
sudo mount -t efs -o tls fsap-09ca9216038ba599e:/ /wordpress-config/efs	
