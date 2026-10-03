# Create the Alvit repository through the canonical GitHub account workspace.
# Private OCI repositories retain local validation without paid protections.
resource "github_repository_vulnerability_alerts" "terraform_oracle_oci_alvit" {
  repository = module.repos["terraform_oracle_oci_alvit"].repository.name
}

resource "github_repository_dependabot_security_updates" "terraform_oracle_oci_alvit" {
  repository = module.repos["terraform_oracle_oci_alvit"].repository.id
  enabled    = true

  depends_on = [github_repository_vulnerability_alerts.terraform_oracle_oci_alvit]
}
