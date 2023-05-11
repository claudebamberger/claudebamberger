### aws cli v2 commands & terraform

* télécharger [awscliv2.pkg](https://awscli.amazonaws.com/AWSCLIV2.pkg) et installer
* vérifier que la configuration générale est bien faite dans ``~/.aws/config``
  ```
  [default]
  region = us-east-1
  output = json
  ```
* aws configure pour renseigner les clés dans ``~/.aws/credentials``

* aws ec2 describe-security-groups
* aws ec2 describe-subnets
* aws ec2 describe-instances
* aws ec2 run-instances

* télécharger [terraform](https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_darwin_arm64.zip) et installer dans ``/usr/local/bin/tf``

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
  provider "aws" {
    region  = "us-east-1"
  }
  ```
* lancer ``tf init`` dans ``land`` (*<span style="color:darkgreen">Terraform has been successfully initialized!</span>*)
* on peut utiliser ``tf fmt`` puis ``tf validate`` avant ``tf apply`` et inspecter ce qu'il ferait

