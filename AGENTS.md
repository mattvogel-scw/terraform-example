# AGENTS.md
Guidance for agentic coding assistants operating in this repository.

## 1) Repository Context
- Primary stack: Terraform (HCL)
- Supporting scripts: Bash in `scripts/`
- Terraform version constraint: `>= 1.4` (`versions.tf`)
- Providers: `hashicorp/null`, `hashicorp/random`, `hashicorp/tls`
- Backend: Terraform `http` backend pointed at localhost for local-only testing
- No Makefile, no language package manager config, no compiled service in this repo

Current file layout:
- `main.tf`: backend config, locals, resources
- `versions.tf`: Terraform and provider constraints
- `variable.tf`: typed inputs + validation
- `outputs.tf`: output contracts
- `templates/generated_credentials.tftpl`: rendered template content
- `scripts/pre-workflow.sh`: pre-run validation pipeline
- `scripts/post-workflow.sh`: post-run inspection/cleanup pipeline

## 2) Rule Files Status
Checked and not present in this repo at this time:
- `.cursorrules`
- `.cursor/rules/`
- `.github/copilot-instructions.md`
If any are added later, treat them as higher-priority constraints and update this file.

## 3) Build / Lint / Test Commands
There is no compile/build step; use Terraform validation + plan as the build equivalent.

Core commands:
- Format check: `terraform fmt -check -diff -recursive`
- Format write: `terraform fmt -recursive`
- Initialize providers/backend: `terraform init -input=false`
- Validate config: `terraform validate`
- Plan changes: `terraform plan -input=false`
- Apply changes: `terraform apply -auto-approve -input=false`
- Destroy changes: `terraform destroy -auto-approve -input=false`
- Print outputs: `terraform output`
- List state nodes: `terraform state list`

Script wrappers:
- Pre-workflow: `./scripts/pre-workflow.sh`
- Post-workflow: `./scripts/post-workflow.sh`

Supported script environment variables:
- `WORK_DIR`
- `REQUIRE_LOCAL_API=1`
- `API_URL=http://localhost:8080/healthz`
- `PLAN_OUTPUT_FILE=tfplan`
- `SHOW_OUTPUTS=1`
- `SHOW_STATE_LIST=1`
- `DESTROY_ON_EXIT=1`
- `CLEAN_PLAN_FILE=1`

Testing (including single-test guidance):
- Current state: no `.tftest.hcl` files are present
- Current state: no Go/Python/JS test harness is configured
- Run all Terraform tests (when added): `terraform test`
- Run a single Terraform test file: `terraform test -filter=tests/<name>.tftest.hcl`
- If `-filter` is unavailable, run from a narrower path via `terraform -chdir=<dir> test`

Recommended verification order:
1. `terraform fmt -check -diff -recursive`
2. `terraform init -input=false`
3. `terraform validate`
4. `terraform plan -input=false`

## 4) Terraform Code Style
Use existing repository conventions unless the task explicitly requests a refactor.

Formatting:
- Always run `terraform fmt -recursive` before finalizing changes
- Keep Terraform default 2-space indentation
- Break long map/list/object expressions across lines for readability
- Keep one logical concern per file where practical

Naming conventions:
- Use `snake_case` for variables, locals, outputs, and resource labels
- Use descriptive resource labels (example style: `suite_metadata`, `rendered_template`)
- Avoid renaming existing variable/output contracts without explicit migration intent

Types and validation:
- Every variable must declare an explicit `type`
- Prefer concrete types (`list(string)`, `map(string)`, `number`) over loose definitions
- Add validation for constraints users can violate (example: `instance_count > 0`)
- Keep validation `error_message` text specific and actionable

Dependency and data flow:
- Prefer explicit references over implicit assumptions
- Use `locals` for derived values reused in multiple blocks
- Avoid unnecessary `depends_on` when attribute references already express dependency
- Keep graph behavior deterministic and easy to read

`for_each` and `count`:
- Prefer `for_each` for stable identity/keyed resources
- Use `count` for numeric cardinality resources
- Keep count-based index math deterministic and bounds-safe

Outputs and sensitive data:
- Mark secret-bearing outputs with `sensitive = true`
- Expose only necessary attributes; avoid outputting full objects
- Keep output contracts stable for downstream tooling

Providers and lockfile:
- Add providers only when required by feature scope
- Define provider source/version constraints in `versions.tf`
- Do not manually edit `.terraform.lock.hcl`; let `terraform init` manage it

Templates:
- Reference template files via `${path.module}/templates/...`
- Keep template variable names explicit and descriptive
- Never expose rendered secrets through non-sensitive outputs

Imports guidance:
- Terraform has no import statements in this codebase
- Equivalent rule: control dependencies through `required_providers`
- Equivalent rule: avoid unnecessary provider additions

## 5) Bash Script Style
Follow conventions in `scripts/pre-workflow.sh` and `scripts/post-workflow.sh`.
- Keep `#!/usr/bin/env bash` and `set -euo pipefail`
- Use helper functions for logging and dependency checks (`log`, `require_cmd` pattern)
- Verify external commands with `command -v` before use
- Quote variable expansions consistently
- Prefer explicit non-interactive Terraform flags in automation
- Keep scripts idempotent and linear

## 6) Error Handling Expectations
- Fail fast on missing prerequisites
- Use prefixed log lines (`[pre-workflow]`, `[post-workflow]`) for traceability
- Reserve `|| true` for non-critical observability operations only
- Do not swallow failures from fmt/init/validate/plan/apply

## 7) State and Backend Safety
- Existing HTTP backend is intentionally local-test-only
- Do not treat current backend configuration as production-ready
- Mirror backend endpoint changes in `README.md`
- Never commit real credentials or production state artifacts

## 8) Agent Change Checklist
Before handing off Terraform changes:
1. Run `terraform fmt -recursive`
2. Run `terraform init -input=false` if provider/module graph changed
3. Run `terraform validate`
4. Run `terraform plan -input=false` for behavior-impacting edits
5. Verify sensitive outputs remain correctly marked
6. Update `README.md` when commands/workflow expectations changed

## 9) Keep This File Current
- Add exact single-test examples once `.tftest.hcl` files exist
- Add Cursor/Copilot rule summaries if those files are introduced
- Add canonical task-runner commands if a `Makefile`/task runner is introduced
