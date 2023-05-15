# aws cli v2 commands & terraform

## CLI v2
* télécharger [awscliv2.pkg](https://awscli.amazonaws.com/AWSCLIV2.pkg) et installer
* vérifier que la configuration générale est bien faite dans ``~/.aws/config`` (NB ``chmod 600``)
  ```
  [default]
  region = …
  output = json
  ``` 
  * ``[default]``(on peut mettre d'autres profiles par ``profile [nom du profile]`` ou/et ``sso-session [nom profile]``)
  * ``region``par exemple us-east-1 ou une autre
  * ``output`` peut aussi être ``text``
* ``aws configure`` pour renseigner les clés dans ``~/.aws/credentials`` (par profile aussi)

* ``aws ec2 describe…`` par exemple
  * ``aws ec2 describe-security-groups``
  * ``aws ec2 describe-subnets``
  * ``aws ec2 describe-instances``
  * ``aws ec2 run-instances`` (attention, creates)

## Terraform
* télécharger [terraform](https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_darwin_arm64.zip) et installer dans ``/usr/local/bin/tf``
* prévoir un .gitignore plus haut (ou racine) avec
    ```
    .terraform/
    .terraform/**
    .terraform.*
    *.tfstate
    *.tfstate.*
    ```

* faire un ``main.tf`` dans un répertoire ``land`` pour vérifier
  ```
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
      }
    }
    required_version = ">= 1.2.0"
  }
  ```
* lancer ``tf init`` dans ``land`` (*<span style="color:darkgreen">Terraform has been successfully initialized!</span>*)
* on peut utiliser ``tf fmt`` puis ``tf validate`` avant ``tf apply`` et inspecter ce qu'il ferait

## Terraform plus sérieusement
* on peut exporter des variables, par exemple depuis ``~/.zprofile``, en les nommant ``TF_VAR_[nom]``
par exemple 
  ```
  TF_VAR_AWS_REGION=us-east-1
  ```
* ensuite on déclare les variables pour les lier dans ``variables.tf`` (par convention)
  ```
  variable "AWS_REGION" {
    description = "région AWS visée, exported shell"
    type        = string
  }
  ```
* faire un ``provider.tf`` au même niveau avec
  ```
  provider "aws" {
    region = var.AWS_REGION
  }
  ```
* on décrit les ressources dans main.tf 

* on peut modulariser avec des sous-répertoires dans la même logique
  * créer un sous-répertoire ``modules`` (par exemple)
  * y créer un sous-répertoire ``landfill`` (pour l'exemple pour le vpc et les aspects réseau)
  * dans ``landfill`` créer ``variables.tf`` avec les variables nécessaires au module
    ```
    variable "secure_cidr" {
      description = "CIDR sûr en entrée, exported shell"
      type        = string
    }
    ```
  * dans ``landfill`` créer ``landfill.tf`` qui va décrire les ressources
  * dans ``landfill`` créer ``output.tf`` qui va produire les objets en sortie (ici les id vpc, sg et subnet, on peut ajouter des ``depends_on = [ ... ]`` s'il y a des dépendances indirectes)
    ```
    output "landline_sg_ssh_id" {
      value = "${aws_security_group.landline_ssh.id}"
    }
    output "landline_subnet_id" {
      value = "${aws_subnet.landlord.id}"
    }
    output "landline_vpc_id" {
      value = "${aws_vpc.landfill.id}"
    }
    ```
  * dans ``main.tf`` on peut appeler le module par
    ```
    module "landfill" {
      source = "./modules/landfill"
      secure_cidr = "${var.AWS_SECURE_CIDR}"
    }
    ```
    et ”consommer“ le résultat par 
    ```
    subnet_id = module.landfill.landline_subnet_id
    ``` 
  * on peut enfin produire des sorties par output comme le module (directement dans ``main.tf``)

* Documentation des ressources dans l'exemple
  
  ```mermaid
    graph TD
    z[.zprofile for exemple] ==> variables
    variables --o TF_VAR_AWS_REGION>TF_VAR_AWS_REGION]
    variables --o TF_VAR_AWS_PRIVATE_KEY_PATH>TF_VAR_AWS_PRIVATE_KEY_PATH]
    variables --o TF_VAR_AWS_PUBLIC_KEY_PATH>TF_VAR_AWS_PUBLIC_KEY_PATH]
    variables --o TF_VAR_AWS_SECURE_CIDR>TF_VAR_AWS_SECURE_CIDR]
    
    TF_VAR_AWS_REGION --> c1[[for exemple 'us-east-1']]
    TF_VAR_AWS_PRIVATE_KEY_PATH --> c2[[a path to local .ssh for example, pem/pub ou other format]]
    TF_VAR_AWS_PUBLIC_KEY_PATH --> c2
    TF_VAR_AWS_SECURE_CIDR --> c3[[les IPs autorisées à entrer en ssh]]

    land/variables.tf --o AWS_LANDFILL_CIDR_BLOCK
    land/variables.tf --o AWS_LANDFILL_SUBNET
    land/variables.tf --o AMI_Ubuntu_LTS22_x86>map AMI_Ubuntu_LTS22_x86 des AMIs par région]

    variables ----.alimentent.-> land/variables.tf ==> main.tf --> module/landfill/landfill.tf

    landfill/variables ==> module/landfill/landfill.tf
    landfill/variables --o secure_cidr>secure_cidr]
    landfill/variables --o landfill_cidr_block>landfill_cidr_block]
    landfill/variables --o landfill_subnet>landfill_subnet]

    TF_VAR_AWS_SECURE_CIDR -.-> secure_cidr
    landfill/variables --o landfill_cidr_block
    landfill/variables --o landfill_subnet
    AWS_LANDFILL_CIDR_BLOCK -.-> landfill_cidr_block
    AWS_LANDFILL_SUBNET -.-> landfill_subnet
    
    module/landfill/landfill.tf --> landfill[landfill VPC]
    landfill -.-> landfill_cidr_block

    module/landfill/landfill.tf --> landlord[landlord subnet]
    landlord -.-> landfill
    landlord -.-> landfill_subnet

    module/landfill/landfill.tf --> landlineIGW[landline GW]
    landlineIGW -.-> landfill

    module/landfill/landfill.tf --> landlineRT[landline RT]
    landlineRT -.-> landfill
    landlineRT -.all.-> landlineIGW

    module/landfill/landfill.tf --> landlineRTA[landline RTA]
    landlineRTA -.-> landlineRT
    landlineRTA -.-> landlord

    module/landfill/landfill.tf --> landline_ssh
    landline_ssh -.-> landfill
    landline_ssh -.port 22/tcp.-> secure_cidr

    main.tf --> landip
    main.tf --> wopr4-vex-key-pair[keypair to connect]
    maint.tf --> wopr4[wopr4 instance]
    wopr4 -.AWS_REGION.-> AMI_Ubuntu_LTS22_x86
    wopr4 -.-> landlord
    wopr4 -.-> landline_ssh
    wopr4 -.-> wopr4-vex-key-pair

    main.tf ==> output[public IP, public ssh key]

  ```