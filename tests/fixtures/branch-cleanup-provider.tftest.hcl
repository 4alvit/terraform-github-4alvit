mock_provider "github" {
  override_during = plan
  mock_data "github_user" {
    defaults = { login = "4alvit", id = "123" }
  }
}
