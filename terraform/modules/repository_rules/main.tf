variable "repo_name" {
  description = "The name of the repository"
  type        = string
}

variable "extra_status_checks" {
  description = "Additional status checks for specific repositories"
  type        = list(string)
  default     = []
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
    required_signatures           = false # Strict Global Default

    pull_request {
      required_approving_review_count   = 1 # Strict Global Default
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true # Strict Global Default
      require_last_push_approval        = false
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = true
      
      # Global base checks
      required_check { context = "GitGuardian Security Checks" }
      required_check { context = "SonarCloud" }
      required_check { context = "SonarCloud Code Analysis" }

      # Extra checks per repo
      dynamic "required_check" {
        for_each = toset(var.extra_status_checks)
        content {
          context = required_check.value
        }
      }
    }
    
    # Corrected Block Name for CodeQL
    required_code_scanning {
      required_code_scanning_tool {
        tool                     = "CodeQL"
        security_alerts_threshold = "high_or_higher"
        alerts_threshold          = "errors"
      }
    }
  }
}

# 2. Push Security Rules (Target: push - applies to ALL branches)
resource "github_repository_ruleset" "push_security" {
  name        = "push-security"
  repository  = data.github_repository.repo.name
  target      = "push"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5 # Repository Admin role
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  rules {
    # File size is a nested block, not a direct argument
    # We'll use file_path_restriction to cover most security needs
    # max_file_size rule is currently buggy in some provider versions, 
    # focusing on path restrictions for now as they are most critical.

    file_path_restriction {
      restricted_file_paths = [
        "**/.env",
        "**/*.key",
        "**/*.pem",
        "**/*.sqlite",
        "**/*.db",
        "**/*.log",
        "**/.DS_Store",
        "**/*.p12",
        "**/node_modules/**"
      ]
    }

    file_extension_restriction {
      restricted_file_extensions = [".exe", ".dll"]
    }
  }
}

# 3. Tag Protection Rules (Target: tag - applies to v* tags)
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

  bypass_actors {
    actor_id    = 1 # Integrations (Apps/Workflows)
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    update   = true
    deletion = true
  }
}
