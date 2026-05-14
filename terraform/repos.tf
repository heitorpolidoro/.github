locals {
  # --- REPOSITORY LIST ---
  # Add new repositories here.
  # Per user request, only 'extra_checks' can be customized.
  # All other security rules follow the strict global defaults.
  repos = {
    ".github" = {
      extra_checks = [
        { context = "Terraform" },
        { context = "DeepSource: Terraform", integration_id = 16372 }
      ]
    }
    "cash_lens" = {
      extra_checks = [
        { context = "build / Build and test", integration_id = 15368 },
        { context = "DeepSource: Code Formatters", integration_id = 16372 },
        { context = "DeepSource: Docker", integration_id = 16372 }
      ]
    }
    "meridian" = {
      extra_checks = [
        { context = "build / Test (Node 24.x)", integration_id = 15368 },
        { context = "DeepSource: JavaScript", integration_id = 16372 },
        { context = "DeepSource: Code Formatters", integration_id = 16372 }
      ]
    }
    "repertoire_hero" = {
      extra_checks = [
        { context = "build / Test (Node 20.x)", integration_id = 15368 },
        { context = "DeepSource: JavaScript", integration_id = 16372 },
        { context = "DeepSource: Code Formatters", integration_id = 16372 }
      ]
    }
    "sigecon" = {
      extra_checks = [
        { context = "Backend Tests" }, # Local CI doesn't have an App ID
        { context = "Frontend Tests" },
        { context = "DeepSource: JavaScript", integration_id = 16372 },
        { context = "DeepSource: Python", integration_id = 16372 },
        { context = "DeepSource: Code Formatters", integration_id = 16372 },
        { context = "DeepSource: Docker", integration_id = 16372 }
      ]
    }
  }
}
