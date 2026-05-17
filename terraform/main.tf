terraform {
  cloud {
    organization = "Polidoro"

    workspaces {
      name = "github-infra"
    }
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = "heitorpolidoro"
}

# --- Module Orchestration ---
# All rules follow the global defaults defined in the module.
# Only extra_status_checks can be customized per repository.
module "repository" {
  for_each = local.repos
  source   = "./modules/repository_rules"

  repo_name           = each.key
  extra_status_checks = lookup(each.value, "extra_checks", [])
}
