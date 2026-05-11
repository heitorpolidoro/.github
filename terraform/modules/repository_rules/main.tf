variable "repo_name" {
  description = "The name of the repository"
  type        = string
}

# --- GLOBAL DEFAULTS (Can be overridden) ---
variable "enforce_signatures" {
  description = "Whether to require signed commits"
  type        = bool
  default     = false
}

variable "required_approvals" {
  description = "Number of required approving reviews"
  type        = number
  default     = 1
}

variable "base_status_checks" {
  description = "Status checks required for all repositories"
  type        = list(string)
  default     = ["GitGuardian Security Checks", "SonarCloud", "SonarCloud Code Analysis"]
}

variable "extra_status_checks" {
  description = "Additional status checks for specific repositories"
  type        = list(string)
  default     = []
}

variable "enable_codeql" {
  description = "Whether to enable CodeQL scanning analysis"
  type        = bool
  default     = true
}

variable "require_code_owner_review" {
  description = "Whether to require review from code owners"
  type        = bool
  default     = true
}

variable "max_file_size" {
  description = "Maximum file size allowed in MB"
  type        = number
  default     = 50
}

variable "max_file_path_length" {
  description = "Maximum length of a file path"
  type        = number
  default     = 256
}

# --- OPTIONAL FEATURES (Per repo) ---
variable "deployment_environments" {
  description = "List of environments that must be successfully deployed to before merge"
  type        = list(string)
  default     = []
}

variable "enable_merge_queue" {
  description = "Whether to enable the GitHub Merge Queue"
  type        = bool
  default     = false
}

variable "enable_code_quality" {
  description = "Whether to enforce code quality requirements"
  type        = bool
  default     = true
}

variable "enable_copilot_review" {
  description = "Whether to enable GitHub Copilot automatic code reviews"
  type        = bool
  default     = false
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
    required_signatures           = var.enforce_signatures
    update_allows_fetch_and_merge = true

    pull_request {
      required_approving_review_count   = var.required_approvals
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = var.require_code_owner_review
      require_last_push_approval        = false
      required_review_thread_resolution = true
      allowed_merge_methods             = ["squash"]
    }

    required_status_checks {
      strict_required_status_checks_policy = true
      do_not_enforce_on_create             = true
      
      dynamic "required_status_check" {
        for_each = toset(concat(var.base_status_checks, var.extra_status_checks))
        content {
          context = required_status_check.value
        }
      }
    }
    
    dynamic "required_deployments" {
      for_each = length(var.deployment_environments) > 0 ? [1] : []
      content {
        required_deployment_environments = var.deployment_environments
      }
    }

    dynamic "merge_queue" {
      for_each = var.enable_merge_queue ? [1] : []
      content {
        check_response_timeout_minutes = 60
        grouping_strategy              = "ALL_GREEN"
        max_entries_to_build           = 5
        max_entries_to_merge           = 5
        merge_method                   = "SQUASH"
        min_entries_to_merge           = 1
      }
    }

    dynamic "scanning_analysis" {
      for_each = var.enable_codeql ? [1] : []
      content {
        required_check_tool {
          tool                     = "CodeQL"
          security_alerts_threshold = "high_or_higher"
          alerts_threshold          = "errors"
        }
      }
    }

    dynamic "code_quality" {
      for_each = var.enable_code_quality ? [1] : []
      content {
        severity = "errors"
      }
    }

    dynamic "copilot_code_review" {
      for_each = var.enable_copilot_review ? [1] : []
      content {
        review_on_push = true
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
    max_file_size        = var.max_file_size
    max_file_path_length = var.max_file_path_length

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
    update   = true # Prevent moving tags
    deletion = true # Prevent deleting tags
  }
}
