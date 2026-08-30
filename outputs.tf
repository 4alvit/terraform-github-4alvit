output "repositories" {
  description = "Created repositories"
  value = {
    for key, mod in module.repos :
    key => {
      name     = mod.repository.name
      html_url = mod.repository.html_url
      ssh_url  = mod.repository.ssh_clone_url
    }
  }
}

output "organization_url" {
  description = "User/organization URL"
  value       = "https://github.com/${var.github_organization}"
}
