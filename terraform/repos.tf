locals {
  # --- CHECK TEMPLATES ---
  # Reusable check sets to avoid redundancy.
  node_24_checks = [
    { context = "build / Test (Node 24.x)" },
    { context = "DeepSource: JavaScript" },
    { context = "DeepSource: Code Formatters" }
  ]

  # --- REPOSITORY LIST --- (trigger enable-codeql)
  repos = {
    ".github" = {
      extra_checks = [
        { context = "Terraform" },
        { context = "DeepSource: Terraform" }
      ]
    }
    "cash_lens" = {
      extra_checks = [
        { context = "build / Build and test" },
        { context = "DeepSource: Code Formatters" },
        { context = "DeepSource: Docker" }
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
        { context = "DeepSource: JavaScript" },
        { context = "DeepSource: Python" },
        { context = "DeepSource: Code Formatters" },
        { context = "DeepSource: Docker" }
      ]
    }
  }
}
