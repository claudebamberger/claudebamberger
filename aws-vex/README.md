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
  
  // TODO
  ```mermaid
    graph TD;
    A --> B;
  ```