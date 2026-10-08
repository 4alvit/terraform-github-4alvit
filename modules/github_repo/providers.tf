terraform {
  required_version = ">= 1.15.7"
  required_providers {
    github = {
      version = "~> 6.0"
      source  = "integrations/github"
    }
  }
}
