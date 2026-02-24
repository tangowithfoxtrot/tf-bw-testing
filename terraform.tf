# pull in the bitwarden-secrets provider for our Terraform project
terraform {
  required_providers {
    bitwarden-secrets = {
      source  = "registry.terraform.io/bitwarden/bitwarden-secrets"
      version = "0.5.4-pre" # current latest released version
    }
  }
  required_version = ">= 0.5.0"
}

variable "api_url" {
  description = "The base URL for the Bitwarden API"
  default    = "https://api.bitwarden.com"
  type        = string
}

variable "identity_url" {
  type        = string
  default     = "https://identity.bitwarden.com"
  description = "The base URL for the Bitwarden Identity API"
}

variable organization_id {
  description = "The ID of the Bitwarden organization to use with the provider"
  type        = string
}

provider "bitwarden-secrets" {
  api_url         = var.api_url
  identity_url    = var.identity_url

  # access_token is a secret; don't provide a default; set BW_ACCESS_TOKEN instead
  # access_token    = ""

  organization_id = var.organization_id
}
