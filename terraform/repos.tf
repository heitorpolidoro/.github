locals {
  # --- REPOSITORY LIST ---
  # Add new repositories here.
  # Per user request, only 'extra_checks' can be customized.
  # All other security rules follow the strict global defaults.
  repos = {
    "cash_lens" = {
      extra_checks = [
        { context = "build / Build and test", integration_id = 15368 },
        { context = "DeepSource: Code Formatters" }
      ]
    }
    "meridian" = {
      extra_checks = [
        { context = "build / Test (Node 24.x)", integration_id = 15368 },
        { context = "DeepSource: JavaScript" },
        { context = "DeepSource: Code Formatters" }
      ]
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
