# Local backend keeps state on your disk in 'terraform.tfstate'
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
