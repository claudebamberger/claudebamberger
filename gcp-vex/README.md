# gcp gcloud commands & terraform

## gcloud

* install [gcloud tools](https://cloud.google.com/sdk/docs/install)
  ou via ``https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-432.0.0-darwin-x86_64.tar.gz``
* untar, copié dans ``~/.gcp/google-cloud-sdk``
* lancer ``./google-cloud-sdk/install.sh``
* qui va renseigner ``.zprofile`` et corriger manuellement
* penser à faire 
```
> gcloud components install log-streaming minikube terraform-tools \
         config-connector app-engine-java \
         app-engine-php gke-gcloud-auth-plugin kubectl
```
* Créer le projet dans la console (PROJECT_ID -> nom-numéro)
* Dans le projet activer Compute Engine
* se connecter avec
```
> gcloud auth login
You are now logged in as [xxx@yyyy.zzz]
> gcloud projects list
...
> gcloud config set project [PROJECT_ID]
```

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
    google = {
      source = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "[PROJECT_ID]"
  region  = "[GCP_REGION]"
}