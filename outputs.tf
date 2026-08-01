output "repositories" {
  description = "Created repositories"
  value = {
    energy_data_rag_pipeline = {
      name     = github_repository.energy_data_rag_pipeline.name
      html_url = github_repository.energy_data_rag_pipeline.html_url
      ssh_url  = github_repository.energy_data_rag_pipeline.ssh_clone_url
    }
    mcp_venus_os = {
      name     = github_repository.mcp_venus_os.name
      html_url = github_repository.mcp_venus_os.html_url
      ssh_url  = github_repository.mcp_venus_os.ssh_clone_url
    }
    solar_forecast_langgraph = {
      name     = github_repository.solar_forecast_langgraph.name
      html_url = github_repository.solar_forecast_langgraph.html_url
      ssh_url  = github_repository.solar_forecast_langgraph.ssh_clone_url
    }
    mqtt_observability_opentelemetry = {
      name     = github_repository.mqtt_observability_opentelemetry.name
      html_url = github_repository.mqtt_observability_opentelemetry.html_url
      ssh_url  = github_repository.mqtt_observability_opentelemetry.ssh_clone_url
    }
    esphome_ble_sensor_patterns = {
      name     = github_repository.esphome_ble_sensor_patterns.name
      html_url = github_repository.esphome_ble_sensor_patterns.html_url
      ssh_url  = github_repository.esphome_ble_sensor_patterns.ssh_clone_url
    }
    fastapi_mqtt_gateway = {
      name     = github_repository.fastapi_mqtt_gateway.name
      html_url = github_repository.fastapi_mqtt_gateway.html_url
      ssh_url  = github_repository.fastapi_mqtt_gateway.ssh_clone_url
    }
    dbus_service_template = {
      name     = github_repository.dbus_service_template.name
      html_url = github_repository.dbus_service_template.html_url
      ssh_url  = github_repository.dbus_service_template.ssh_clone_url
    }
    profile_4alvit = {
      name     = github_repository.profile_4alvit.name
      html_url = github_repository.profile_4alvit.html_url
      ssh_url  = github_repository.profile_4alvit.ssh_clone_url
    }
    terraform_github_victron = {
      name     = github_repository.terraform_github_victron.name
      html_url = github_repository.terraform_github_victron.html_url
      ssh_url  = github_repository.terraform_github_victron.ssh_clone_url
    }
    home_assistant = {
      name     = github_repository.home_assistant.name
      html_url = github_repository.home_assistant.html_url
      ssh_url  = github_repository.home_assistant.ssh_clone_url
    }
    iot_project_builder_profile = {
      name     = github_repository.iot_project_builder_profile.name
      html_url = github_repository.iot_project_builder_profile.html_url
      ssh_url  = github_repository.iot_project_builder_profile.ssh_clone_url
    }
  }
}

output "organization_url" {
  description = "User/organization URL"
  value       = "https://github.com/${var.github_organization}"
}