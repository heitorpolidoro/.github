locals {
  # --- CHECK TEMPLATES ---
  # Reusable check sets to avoid redundancy.
  node_24_checks = [
    { context = "build / Test (Node 24.x)", integration_id = 15368 },
    { context = "DeepSource: JavaScript", integration_id = 16372 },
    { context = "DeepSource: Code Formatters", integration_id = 16372 }
  ]

  # --- REPOSITORY LIST ---
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
      extra_checks = local.node_24_checks
    }
    "repertoire-hero" = {
      extra_checks = local.node_24_checks
    }
    "sigecon" = {
      extra_checks = [
        { context = "Backend Tests" },
        { context = "Frontend Tests" },
        { context = "DeepSource: JavaScript", integration_id = 16372 },
        { context = "DeepSource: Python", integration_id = 16372 },
        { context = "DeepSource: Code Formatters", integration_id = 16372 },
        { context = "DeepSource: Docker", integration_id = 16372 }
      ]
    }
  }
}
