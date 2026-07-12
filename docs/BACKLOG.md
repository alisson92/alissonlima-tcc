# Backlog — Próximos Passos

Checklist vivo de trabalho pendente neste repositório. Itens são adicionados
conforme surgem e marcados como concluídos (com data e referência de commit/PR)
conforme forem resolvidos. Segue o mesmo espírito do antigo
`HARDENING_CHECKLIST.md` (removido após fechar 100% dos itens em 2026-07-06).

Convenção: `[ ]` pendente · `[x]` concluído · cada item concluído ganha uma linha
"Resolvido em" com data e commit/PR.

---

## CI / Qualidade

- [ ] **Triagem de findings tflint** — `.tflint.hcl` (raiz) já roda em modo
  `continue-on-error: true` na matrix de 12 módulos e encontrou findings reais
  (outputs sem `description` nos módulos Azure). Falta decidir, por finding:
  corrigir ou suprimir com justificativa no `.tflint.hcl`.
- [ ] **Triagem de findings Trivy** — `trivy.yaml` (raiz) roda em modo
  não-bloqueante (`exit-code: 0`) e encontrou 2 findings, ambos aparentando ser
  riscos já aceitos e documentados: NSG do app tier Azure com
  `source_address_prefix = "*"` (documentado no `main.tf`, item #4 do antigo
  `HARDENING_CHECKLIST.md`) e listener HTTP do ALB sem HTTPS (intencional — TLS
  termina na Cloudflare). Falta confirmar formalmente e suprimir via
  `skip-check` com justificativa, em vez de deixar como finding "solto".
- [ ] **Flipar tflint/Trivy para bloqueantes** — só depois das duas triagens
  acima.
- [ ] **Adicionar tflint/Trivy como required status checks** no GitHub Ruleset
  `protect-main-develop` (ver histórico em memória `project_branch_protection_hardening`)
  — só depois do item anterior.
- [ ] **`required_status_checks` no ruleset** (mais amplo, incluindo `fmt`/`validate`
  de `pr-validate.yml`) — estava deliberadamente adiado até o pipeline provar
  estabilidade em mais PRs; reavaliar.
- [ ] **Composite action** para eliminar duplicação de
  checkout+setup-terraform+init entre os 5 jobs de CI hoje existentes — chore
  separado, deliberadamente adiado.

## Infraestrutura / Terraform

- [ ] **`aws/teste` e `aws/homol`: `app_server_count` não é passado ao módulo
  `app_environment`** em `main.tf` (só `prod` passa). Hoje inofensivo porque o
  default do módulo já é `1` em ambos os casos — inconsistência cosmética, não
  bug funcional.

## Governança do repositório (GitHub)

- [ ] **Backup/mirror do repositório** — GitHub não tem "prevent repo deletion"
  nativo para conta pessoal (só confirmação por digitação + restore window de
  ~90 dias). Usuário já viu as opções (mirror manual vs. automatizado via
  Actions) e preferiu não decidir ainda. Revisitar se o tema de
  disaster-recovery/backup voltar à tona.

---

## Concluído recentemente (histórico curto, para contexto)

- [x] **Migração do Load Balancer Azure de L4 (Standard LB) para L7
  (Application Gateway)** — em `prod`, refresh sucessivo na URL alternava
  entre `app-server-0`/`app-server-1` na AWS (ALB, roteamento por
  requisição), mas nunca na Azure. Causa raiz: `azurerm_lb` Standard decide o
  backend uma vez por conexão TCP (hash de 5-tupla), e o DNS proxied no
  Cloudflare mantém conexões persistentes com a origem — a alternância nunca
  ficava visível mesmo com as 2 VMs saudáveis e corretamente associadas ao
  backend pool. Migrado `modules/azure/load_balancer` para
  `azurerm_application_gateway` (Standard_v2, capacidade fixa = 1,
  `cookie_based_affinity = "Disabled"`), que roteia por requisição HTTP como
  o ALB. Efeito colateral: a subnet `public_b`, órfã desde a remoção do NSG
  do ALB antigo (item abaixo), foi reaproveitada como subnet dedicada do
  Application Gateway. Mudança aplicada ao módulo compartilhado (vale para
  `teste`/`homol`/`prod`), mas só testada/validada em `prod`, único ambiente
  com `app_server_count > 1` — `teste`/`homol` herdam o módulo novo (AppGW
  com 1 backend, comportamento equivalente ao LB antigo) sem necessidade de
  reteste, e passam a pagar o custo por hora do Standard_v2 (maior que o
  Standard LB) sempre que subirem. Resolvido em 2026-07-12 — branch
  `feat/azure-appgw-l7-loadbalancer`.
- [x] **Subnet `public_b` órfã no Azure** (`modules/azure/networking/main.tf`)
  — ficou sem uso depois que a remoção do NSG do ALB órfão (item #3 do antigo
  hardening) parou de referenciá-la. Resolvida como efeito colateral da
  migração para Application Gateway acima: renomeada para `appgw` e virou a
  subnet dedicada do novo Application Gateway. Resolvido em 2026-07-12 —
  branch `feat/azure-appgw-l7-loadbalancer`.
- [x] **Criação deste checklist** (`docs/BACKLOG.md`) — consolidação das
  pendências antes espalhadas em memória de conversa. Resolvido em
  2026-07-10 — branch `docs/add-backlog-checklist` → PR #42 (squash merge em
  `develop`, `29464e8`) → PR #43 (squash merge em `main`, `ddc4599`).
- [x] **Verificação de paridade anteprojeto x código** — nenhuma lacuna
  encontrada entre os 5 objetivos específicos do anteprojeto (`docs/ANTEPROJETO
  - ALISSON CORREA LIMA.doc`) e o código atual. README atualizado para
  documentar itens "a mais" (Load Balancer, SSL na Cloudflare,
  `playbook_nginx_container.yml`) que não apareciam em lugar nenhum da
  documentação. Resolvido em 2026-07-10 — branch
  `docs/readme-parity-anteprojeto` → PR #40 (squash merge em `develop`,
  `8db680f`) → PR #41 (squash merge em `main`, `7d76a9c`).
- [x] **4 gates de qualidade de CI** (tflint, Trivy, terraform-docs-check,
  terraform test) + documentação (`docs/CI-QUALIDADE.md`). Resolvido em
  2026-07-08 — PRs #36-39, mergeados em `develop`/`main`.
- [x] **Branch protection hardening** — GitHub Ruleset `protect-main-develop`
  + secret scanning + Dependabot. Resolvido em 2026-07-07.
- [x] **Terraform best practices** — `versions.tf` por módulo, split do
  `backend.tf` do Azure, READMEs via `terraform-docs`, limpeza da raiz.
  Resolvido em 2026-07-07.
- [x] **Hardening/cleanup geral** (19 findings: 1 crítico, 5 alto, 7 médio,
  3 baixo, incluindo purge de `terraform.tfvars` do histórico git). Resolvido
  em 2026-07-06.
