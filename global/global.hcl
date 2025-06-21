terraform {
  cloud {
    hostname     = "app.terraform.io"        # optional; defaults to this
    organization = "JFKTBonny-and-co"        # your Terraform Cloud org

    workspaces {
      name = "global"
    }
  }
}