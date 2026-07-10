# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This is a TCC (undergraduate thesis) project: a multi-cloud Infrastructure-as-Code framework that provisions equivalent application environments (Teste, Homologação, Prod) on both **AWS** and **Azure** using Terraform, configured post-provisioning with **Ansible**, and orchestrated entirely through a single **GitHub Actions** workflow (no local `terraform apply` in normal operation).

## Commands

There is no local build/test suite — this is pure IaC. All lifecycle operations are meant to run through the GitHub Actions workflow `.github/workflows/main.yml` ("Orquestrador Multicloud TCC"), triggered manually via `workflow_dispatch` with inputs: `provider` (azure|aws), `environment` (teste|homol|prod), `action` (apply|destroy|force-unlock), and `lock_id` (only for force-unlock).

For local iteration/validation of a single environment:
```bash
cd environments/<aws|azure>/<teste|homol|prod>
terraform init
terraform validate
terraform plan \
  -var="create_environment=true" \
  -var="cloudflare_api_token=..." \
  -var="cloudflare_zone_id=..."
```
Each environment directory also expects a local `terraform.tfvars` (gitignored — never commit it; it holds `my_ip`, `instance_type`, `app_server_count`, etc.).

To bootstrap AWS remote state (S3 bucket + DynamoDB lock table), see `backend/aws/main.tf` — this is a one-time, separate root module, not part of the per-environment apply.

Ansible playbooks (`ansible/playbook_docker.yml`, `ansible/playbook_nginx_container.yml`) are only ever invoked by the pipeline against a dynamically generated `inventory.ini`, proxied through the Bastion host. They are not meant to be run ad hoc against arbitrary hosts.

## Git workflow (GitFlow)

This project follows a GitFlow-style branching model with `main` and `develop` as the permanent branches:

1. Always branch off **`main`** for new work (feature/fix/chore branch), never off `develop`.
2. Make the changes, validate/test locally as applicable.
3. Open a PR from that branch into **`develop`**.
4. After merging to `develop`, validate/test again from `develop`.
5. Only then open a PR from `develop` into **`main`**.

Never push directly to `main` or `develop` — always go through a PR, and always test at each stage (branch → develop, and develop → main) before promoting.

## Commit workflow

- **One file per commit, always.** Stage and commit changed files individually (`git add <single-file>` → `git commit`); never `git add .` / `git add -A`, and never bundle multiple changed files into one commit message — even when a fix logically spans more than one file (e.g. a module's `main.tf` and its matching `variables.tf`). Do N separate add+commit cycles for N changed files.
- All commit messages follow Conventional Commits (`fix:`, `chore:`, `refactor:`, `security:`, `docs:`, etc.), imperative mood, English.
- Do not commit or push without the user's explicit confirmation for that specific change — this holds per item even within a larger reviewed list (e.g. `HARDENING_CHECKLIST.md`), not just once for the whole batch.
- When resolving an item tracked in `HARDENING_CHECKLIST.md`, update that file's checkbox, commit hash, and summary table as part of wrapping up the item.

## Architecture

### Layered module composition

Each `environments/<provider>/<env>/main.tf` wires reusable modules from `modules/<provider>/` together in a fixed dependency chain (see e.g. `environments/aws/prod/main.tf`):

1. **networking** — VPC, public/private subnets across AZs
2. **security** — Security Groups / NSGs for bastion, ALB, and app/db tier (least-privilege, referencing each other by ID rather than CIDR)
3. **data_storage** — persistent volume for the DB server, pinned to the AZ networking chose
4. **app_environment** — app server(s) (`app_server_count`) + DB server, private subnet only
5. **bastion** (module block named `bastion_host` in both AWS and Azure) — the sole public SSH entry point
6. **load_balancer** — ALB/equivalent in front of the app servers

Every module block is gated with `count = var.create_environment ? 1 : 0`. This is the central pattern of the whole framework: setting `create_environment=false` and re-applying destroys all resources in an environment **without deleting any Terraform code**, so environments can be torn down between uses to save cost and recreated identically later. When editing any environment `main.tf`, preserve this toggle and the `module.x[0]` indexing it implies.

### DNS split

`dns.tf` in each AWS/Azure environment handles two distinct concerns:
- **Public DNS** via the `cloudflare` provider (proxied CNAME to the load balancer, unproxied A record to the bastion) — SSL/TLS is terminated at Cloudflare, not on the ALB.
- **Private DNS** via `aws_route53_zone`/equivalent, VPC-associated, resolving internal hostnames like `db-server` and `app-server` for cross-node communication that never touches the public internet. The hostname is only index-suffixed (`app-server-0`, `app-server-1`, ...) when `app_server_count > 1` (currently only `prod`); single-instance environments (`teste`, `homol`) resolve the unsuffixed `app-server`.

### Provider parity, not shared code

AWS and Azure implementations are **not** abstracted behind a common module — `modules/aws/*` and `modules/azure/*` are independent, parallel implementations of the same six-module architecture. When asked to change behavior "for both clouds," expect to make near-identical edits in both trees rather than finding one shared source.

### State backend

- AWS: S3 bucket `alissonlima-tcc-terraform-state` + DynamoDB table `alissonlima-tcc-terraform-state-lock` for locking, one state key per environment (`aws/<env>/terraform.tfstate`). Bootstrapped by `backend/aws/main.tf`, declared in each environment's `backend.tf`.
- Azure: Storage Account `alissonlimatcctfstate` (container `tfstate`) for state, one blob key per environment (`environments/azure/<env>/terraform.tfstate`). Bootstrapped by `backend/azure/main.tf`, declared in each environment's `backend.tf` — same file-per-concern layout as AWS.

### CI/CD pipeline shape

`.github/workflows/main.yml` has two parallel provider branches (`terraform_azure`/`configure_azure_servers` and `terraform_aws`/`configure_aws_servers`), gated by the `provider` input via `if:` conditions. Each branch: runs Terraform, opens SSH ingress just-in-time for the GitHub runner's IP on the bastion SG/NSG, generates an Ansible inventory from Terraform outputs (bastion as jump host via `ProxyCommand`), runs the two playbooks, then always closes the just-in-time SSH rule again (`if: always()`). When modifying the pipeline, keep the JIT-open/JIT-close pairing intact — leaving the rule open is a security regression.

### Access model

Documented in `docs/ACESSOS.md`: all internal access (app/db servers) is via SSH Agent Forwarding (`-A`) through the environment-and-provider-specific bastion (e.g. `bastion-aws-prod.alissonlima.dev.br`), then plain `ssh` to internal hostnames (`app-server.internal.alissonlima.dev.br`, indexed as `app-server-N...` only where `app_server_count > 1`; `db-server.internal.alissonlima.dev.br`) resolved by the private Route53/DNS zone.
