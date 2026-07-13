# Backlog — Próximos Passos

Checklist vivo de trabalho pendente neste repositório. Itens são adicionados
conforme surgem e marcados como concluídos (com data e referência de commit/PR)
conforme forem resolvidos. Segue o mesmo espírito do antigo
`HARDENING_CHECKLIST.md` (removido após fechar 100% dos itens em 2026-07-06).

Convenção: `[ ]` pendente · `[x]` concluído · cada item concluído ganha uma linha
"Resolvido em" com data e commit/PR.

---

## CI / Qualidade

- [x] **Triagem de findings tflint** — a primeira passada (2026-07-12, branch
  `chore/tflint-networking-output-descriptions`) tratou só 5 outputs sem
  `description` em `modules/azure/networking`, mas a triagem estava
  incompleta: rodando `tflint v0.63.1` (versão do CI) nos 12 módulos da
  matrix apareceram **13 findings reais em mais 4 módulos Azure**. Todos
  corrigidos:
  - 7 variáveis sem `description` (`modules/azure/data_storage`,
    `modules/azure/app_environment`) — documentadas.
  - 3 variáveis não usadas — dead code confirmado por `grep` (nunca
    referenciadas em `main.tf`, sem equivalente de paridade na AWS):
    `vnet_cidr_block` (`modules/azure/security`), `admin_username` e
    `private_dns_zone_name` (`modules/azure/app_environment`) — removidas
    junto com os argumentos correspondentes nos 3
    `environments/azure/*/main.tf` e nos `tests/main.tftest.hcl`.
  - `Standard_B1s` (VM size com retirement anunciado para nov/2028, ver
    Microsoft Learn) trocado por `Standard_B2ts_v2` em 5 lugares
    (`modules/azure/app_environment`, `modules/azure/bastion`,
    `environments/azure/{teste,homol,prod}`). Primeira tentativa usou
    `Standard_B1s_v2`, que não existe na família Bsv2 — corrigido depois que
    o próprio `tflint` acusou `invalid value as size`.
  - `terraform validate` nos 3 ambientes Azure e `terraform test` nos
    módulos `security`/`app_environment` confirmaram nada quebrado.
  Resolvido em 2026-07-13 — branch `chore/flip-tflint-trivy-blocking`.
- [x] **Triagem de findings Trivy** — `trivy.yaml` (raiz) roda em modo
  não-bloqueante (`exit-code: 0`). Os 2 achados originais já estão
  formalmente suprimidos via `.trivyignore`: NSG com
  `source_address_prefix = "*"` (`AZU-0047`) e listener HTTP do ALB sem
  HTTPS (`AVD-AWS-0054`, intencional — TLS termina na Cloudflare).
  Resolvido em 2026-07-12 — branch `security/suppress-alb-http-listener-trivy`.
- [x] **Flipar tflint/Trivy para bloqueantes** — removido
  `continue-on-error: true` do job `tflint` e trocado `exit-code: '0'` →
  `'1'` no job `trivy` em `.github/workflows/pr-validate.yml`, só depois de
  validar localmente que os 12 módulos passam limpo no tflint. Resolvido em
  2026-07-13 — branch `chore/flip-tflint-trivy-blocking`.
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

- [x] **Supressão formal do finding Trivy `AVD-AWS-0054`** (listener HTTP do
  ALB sem HTTPS) — segundo e último dos 2 achados originais do Trivy. ID
  confirmado rodando `trivy config modules/aws/load_balancer` localmente
  (não estava documentado em lugar nenhum do repo antes, só em prosa).
  Risco aceito e intencional: o TLS termina na Cloudflare (proxied), nunca
  no Load Balancer — adicionar um listener HTTPS no ALB exigiria gerenciar
  certificados via ACM duplicando o que a Cloudflare já cumpre. Suprimido
  via `.trivyignore`, mesmo padrão usado para `AZU-0047`. Resolvido em
  2026-07-12 — branch `security/suppress-alb-http-listener-trivy`.
- [x] **Supressão formal do finding Trivy `AZU-0047`** (NSG ingress `*` na
  porta 80) — a migração para Application Gateway duplicou a regra já aceita
  do NSG `application` em um segundo NSG (`appgw`), e o GitHub code scanning
  passou a reportar isso como "3 novos alertas críticos" no PR #53, mesmo
  sendo o mesmo risco já documentado (Cloudflare não faz SNAT no caminho de
  entrada — o NSG nunca vê o IP real do cliente). Primeira tentativa de
  supressão via `misconfiguration.skip-check` em `trivy.yaml` não teve efeito
  algum — essa chave não existe no schema do Trivy 0.70 e era ignorada
  silenciosamente (confirmado rodando o mesmo binário/versão do CI
  localmente). Supressão real feita via `.trivyignore` (raiz do repo,
  descoberto automaticamente pelo Trivy), com justificativa inline.
  Resolvido em 2026-07-12 — branch `feat/azure-appgw-l7-loadbalancer`.
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
