# Documentação de Instruções para Configuração de Projeto Docker

## Visão Geral

O projeto envolve a implantação de um aplicativo WordPress em contêineres Docker e a configuração de um Elastic Load Balancer (ELB) para garantir a alta disponibilidade e escalabilidade da aplicação. O processo é composto por várias etapas, incluindo a configuração de instâncias EC2, instalação do Docker e Docker Compose, montagem de sistemas de arquivos distribuídos, criação e execução de contêineres, configuração de um ELB e verificação do estado de integridade das instâncias.

## Pré-Requisitos

Antes de iniciar a configuração do projeto, devemos nos certificar de ter configurado dos seguintes pontos:

1. Uma VPC (Virtual Private Cloud) configurada com sub-redes públicas em duas zonas de disponibilidade diferentes.
2. Um modelo de execução de instância que inclua as mesmas tags usadas na primeira atividade.

## Passo 1: Configuração das Instâncias EC2

Para criar um ambiente Docker pronto, siga os seguintes passos:

1. Crie um script de inicialização das instâncias chamado `user_data.sh` com o seguinte conteúdo:

```
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo yum install mysql -y
sudo service docker start
sudo usermod -aG docker ec2-user
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo mkdir /wordpress-config
cd /wordpress-config/
sudo mkdir efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0706de9a2fda442cc.efs.us-east-1.amazonaws.com:/ /wordpress-config/efs
echo "version: '3.1'

services:

  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: wordpress.cyg9xyvzl1qw.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: admin123
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress:/var/www/html
      - /wordpress-config/efs

  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: admin
      MYSQL_PASSWORD: admin123
      MYSQL_RANDOM_ROOT_PASSWORD: '1'
    volumes:
      - db:/var/lib/mysql

volumes:
  wordpress:
  db:" >> docker-compose.yml
docker-compose -f docker-compose.yml up -d
```


Este script executa as seguintes ações:

- Atualiza a instância.
- Instala o Docker e o Docker Compose.
- Instala o MySQL.
- Inicia o serviço Docker.
- Adiciona o usuário `ec2-user` ao grupo `docker`.
- Baixa e instala o Docker Compose.
- Cria um diretório para configurações do WordPress.
- Monta um sistema de arquivos distribuídos usando NFS.

Inicie uma instância EC2 usando o modelo de execução desejado e adicione o script `user_data.sh` como parte do processo de inicialização.

## Passo 2: Configuração do Elastic Load Balancer (ELB)

Agora, configuramos o Elastic Load Balancer (ELB) para distribuir o tráfego entre as instâncias.

1. No Console da AWS, navegue até o serviço "Elastic Load Balancing".
2. Crie um novo ELB, selecionando o esquema voltado para a internet e configurando as sub-redes públicas e duas zonas de disponibilidade.
3. Configure o ELB para direcionar o tráfego para as instâncias EC2 criadas anteriormente.
4. Crie um grupo de destino que inclua as instâncias EC2 e verifique o estado de integridade das instâncias.

## Conclusão

Após a conclusão dessas etapas, o projeto estará configurado e em execução em um ambiente na AWS. Ao acessar o DNS do load balancer, é possível verificar que a aplicação está funcionando conforme o esperado.
