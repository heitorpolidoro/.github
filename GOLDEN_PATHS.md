# 🌟 Golden Paths: Centralized Infrastructure & CI/CD

This document summarizes the centralized infrastructure and "Golden Paths" created to standardize all repositories under the `@heitorpolidoro` account.

## 🏗️ Repository Management (Terraform)
All repository settings and branch protections (Rulesets) are managed via Terraform in the `/terraform` directory of the `.github` repository.

- **Centralized Rules**: One place to change security standards for all repos.
- **Rulesets**: 
  - `master-protection`: Enforces PRs, 1 approval, Squash merge, SonarCloud, and CodeQL.
  - `tag-protection`: Protects `v*` release tags from deletion/modification.
- **Automation**: GitHub Actions automatically `plan` on PRs and `apply` on merges to `master`.

---

## 🚀 Reusable Workflows (Golden Paths)
We have centralized CI/CD logic into reusable workflows located in `.github/workflows/` of this repository. This eliminates boilerplate and standardizes quality checks.

### 1. Node.js Standard CI
**File**: `node-standard-ci.yml`
- **Features**: Multi-version matrix, `npm ci`, Vitest/Jest coverage, SonarCloud, DeepSource.
- **Usage**:
```yaml
jobs:
  build:
    uses: heitorpolidoro/.github/.github/workflows/node-standard-ci.yml@master
    with:
      node-versions: "['22.x', '24.x']"
    secrets: inherit
```

### 2. Elixir Standard CI
**File**: `elixir-standard-ci.yml`
- **Features**: BEAM setup, Mix cache, Postgres service, `mix quality_check`, ExCoveralls, SonarCloud.
- **Usage**:
```yaml
jobs:
  build:
    uses: heitorpolidoro/.github/.github/workflows/elixir-standard-ci.yml@master
    with:
      postgres-db: "your_app_test"
      sonar-project-key: "heitorpolidoro_your_app"
    secrets: inherit
```

### 3. Python Standard CI (uv)
**File**: `python-standard-ci.yml`
- **Features**: `uv` setup & cache, Pytest coverage, SonarCloud.
- **Usage**:
```yaml
jobs:
  build:
    uses: heitorpolidoro/.github/.github/workflows/python-standard-ci.yml@master
    with:
      sonar-project-key: "heitorpolidoro_your_app"
    secrets: inherit
```

---

## 🔐 Secret Management
All workflows use `secrets: inherit`. This means the calling repository (e.g., `meridian`) must have the following secrets configured locally:
- `SONAR_TOKEN` (Required for all)
- `DEEPSOURCE_DSN` (Required for Node.js)

The `.github` repository must have these for Terraform:
- `TF_API_TOKEN` (Terraform Cloud)
- `ORG_TERRAFORM_TOKEN` (GitHub PAT with Admin rights)

---

## 📈 Next Steps
- Migrate remaining repositories to call these reusable workflows.
- Centralize `sigecon` (Fullstack) CI logic.
- Implement a global Pull Request template.
