locals {
  # --- REPOSITORY LIST ---
  # Add new repositories here.
  # Per user request, only 'extra_checks' can be customized.
  # All other security rules follow the strict global defaults.
  repos = {
    "cash_lens" = {
      extra_checks = ["build / Build and test"]
    }
    "meridian" = {
      extra_checks = ["build / Test (Node 24.x)"]
    }
    "sigecon" = {
      extra_checks = [
        "Backend Tests",
        "Frontend Tests",
      ]
    }
  }
}
