#!/bin/bash
sudo yum update -y

# Instala o Docker
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -aG docker ec2-user

# Faz o deploy de um contêiner de aplicação WordPress
git clone https://github.com/MoreiraGabriel95/Atividade-AWS-Docker
cd Atividade-AWS-Docker
docker-compose -f docker-compose.yml up -d

# Configuração do EFS para estáticos do container de aplicação WordPress
sudo mkdir /efs
sudo mount -t efs -o tls fs-0535e06fb6663b786:/ /efs
sudo echo 'fs-0535e06fb6663b786:/ /efs efs _netdev 0 0' >> /etc/fstab
