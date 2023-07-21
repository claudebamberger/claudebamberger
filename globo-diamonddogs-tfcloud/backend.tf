terraform {
  cloud {
    organization = "globomantics-claudebbg"

    workspaces {
      name = "diamonddogs-app-useast1-dev"
    }
  }
}
