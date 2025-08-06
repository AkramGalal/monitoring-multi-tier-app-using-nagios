# Monitoring Multi-tier Java application using Nagios

## Introduction
This project monitors the operation of a multi-tier Java microservices application hosted on 5 VirtualBox machines using Nagios. 

## Architecture
The application architecture is composed of 5 microservices, each one will be deployed on a separate VM. Nagios is deployed on a separate VM, and it will be used to monitor the 5 VMs of the application, besides the corresponding service one. The VMs and services are listed as follows.

| VM              | Service                | VM Hostname |
|-----------------|------------------------|-------------|
| Load Balancer   | Nginx                  | `web01`     |
| Application     | Tomcat                 | `app01`     |
| Message Queue   | RabbitMQ               | `rmq01`     |
| Cache           | Memcached              | `mc01`      |
| Database        | MariaDB                | `db01`      |
| Monitoring      | Nagios                 | `nag01`     |

<img width="2048" height="1302" alt="image" src="https://github.com/user-attachments/assets/8d9c68fa-2f3c-4a95-b9e6-da550952c2be" />

## Requirements
- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)
- Vagrant plugins.

## Setup and Deployment
- Install VirtualBox.
- Install Vagrant.
- Clone the repository.
- Install Vagrant plugins.
  ```bash
  vagrant plugin install vagrant-hostmanager
  ```
- Automate the creation and provisioning of the VMs using the associated Bash scripts.
  ```bash
  vagrant up
  ```
- Access Nagios UI dashboard usig the IP address of Nagios VM.
- Dashboard username: nagiosadmin and no password.
- Note: If hosts/services are not fetched correctly on Nagios, try to restart nrpe service on each VM.
 ```bash
sudo systemctl restart nrpe
 ```

## Nagios Hosts
- Here is Nagios dashboard shows the 5 VMs of the application besides the localhost (Nagios VM).
 ![Image](https://github.com/user-attachments/assets/57ab5d3a-4a02-4e2f-94cd-e6e87e2087b6)

## Nagios Services
- Here is Nagios dashboard shows the 5 services.
 ![Image](https://github.com/user-attachments/assets/32bbd031-1387-4f02-b141-f3b68a60ddb7)

## Packaging Vagrant Boxes
- Packaging each VM, i.e., converting it to a Vagrant Box:
  ```bash
    vagrant package db01 --output web01.box
    vagrant package mc01 --output mc01.box
    vagrant package rmq01 --output rmq01.box
    vagrant package app01 --output app01.box
    vagrant package web01 --output web01.box
    vagrant package nag01 --output nag01.box
  ```
## Uploading Boxes to Vagrant Cloud
- Log in to Vagrant Cloud.
- Upload the ".box" file for each VM.

### Built Boxes
- [web01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/web01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
- [app01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/app01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
- [rmq01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/rmq01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
- [mc01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/mc01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
- [db01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/db01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
- [nag01](https://portal.cloud.hashicorp.com/services/vagrant/registries/multi-tier-java-web-app-project1-boxes/boxes/nag01?project_id=f92dac97-833c-445f-b97f-2d0948d624c9)
