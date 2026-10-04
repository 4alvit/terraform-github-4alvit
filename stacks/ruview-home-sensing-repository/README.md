# RuView home sensing repository

This independent Terraform root owns the private `4alvit/ruview-home-sensing`
repository, vulnerability alerts and Dependabot security updates. It follows the
existing independent repository-stack pattern and neither imports nor changes
the top-level canonical state.

State: `victron-venus/github-ruview-home-sensing-repository`, local execution.
Use the existing HCP credentials and a `GITHUB_TOKEN` for account `4alvit`.
The first reviewed plan must have exactly three creates and no changes or
deletions. Apply the saved plan, verify private visibility, then verify a
no-change plan. Never commit state, saved plans or credentials.

Application Kubernetes resources have separate state, documented in the private
application repository.
