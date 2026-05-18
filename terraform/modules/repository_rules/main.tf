variable "repo_name" {
  description = "The name of the repository"
  type        = string
}

variable "extra_status_checks" {
  description = "Additional status checks for specific repositories"
  type = list(object({
    context        = string
    integration_id = optional(number)
  }))
  default = []
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Fetch existing repository data
data "github_repository" "repo" {
  full_name = "heitorpolidoro/${var.repo_name}"
}

# 1. Branch Protection Rules (Target: master)
resource "github_repository_ruleset" "master" {
  name        = "master-protection"
  repository  = data.github_repository.repo.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 5 # Repository Admin role
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    creation                      = true
    update                        = true
    deletion                      = true
    non_fast_forward              = true
    required_linear_history       = true
    required_signatures           = false

    pull_request {
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = false
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = true
      
      # Global base checks
      # Setting integration_id = 0 (Any Source) prevents 422 errors on repos without the App installed
      required_check {
        context        = "GitGuardian Security Checks"
        integration_id = 0
      }
      required_check {
        context        = "SonarCloud"
        integration_id = 0
      }
      required_check {
        context        = "SonarCloud Code Analysis"
        integration_id = 0
      }
      required_check {
        context        = "DeepSource: Secrets"
        integration_id = 0
      }

      # Extra checks per repo
      dynamic "required_check" {
        for_each = { for idx, check in var.extra_status_checks : idx => check }
        content {
          context        = required_check.value.context
          integration_id = coalesce(required_check.value.integration_id, 0)
        }
      }
    }
    
    required_code_scanning {
      required_code_scanning_tool {
        tool                     = "CodeQL"
        security_alerts_threshold = "high_or_higher"
        alerts_threshold          = "errors"
      }
    }
  }
}

# Note: Push Security Rules (Target: push) were removed because they are only supported 
# for Org-owned repositories in GitHub Enterprise.

# 2. Tag Protection Rules (Target: tag - applies to v* tags)
resource "github_repository_ruleset" "tags" {
  name        = "tag-protection"
  repository  = data.github_repository.repo.name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = 5 # Repository Admin role
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    update   = true
    deletion = true
  }
}
