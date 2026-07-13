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
    o próprio `tflint` acusou `invalid value as size`. **Essa troca foi
    revertida no dia seguinte** — ver item "Incidente: apply quebrado por
    troca de VM size" abaixo.
  - `terraform validate` nos 3 ambientes Azure e `terraform test` nos
    módulos `security`/`app_environment` confirmaram nada quebrado.
  Resolvido em 2026-07-13 — branch `chore/flip-tflint-trivy-blocking`.
- [x] **Incidente: apply quebrado por troca de VM size (Standard_B2ts_v2)** —
  ao validar o PR #59 com `apply` real em `teste`/`homol`/`prod` via pipeline
  (2026-07-13), os 3 ambientes falharam: `409 Conflict — exceeding approved
  standardBsv2Family Cores quota (Current Limit: 0)`. A troca de
  `Standard_B1s` (família Bv1, cota já aprovada) para `Standard_B2ts_v2`
  (família Bsv2, nunca usada nesta subscription) não validou cota disponível
  antes de aplicar — o retirement do B1s só é em nov/2028, não havia
  urgência real para forçar a migração. Application Gateway chegou a ser
  criado nos 3 ambientes antes da falha nas VMs (infra parcial, sem perda,
  reaplicável). Correção: revertido `vm_size`/`instance_type` para
  `Standard_B1s` nos mesmos 5 lugares, e a regra
  `azurerm_linux_virtual_machine_retired_size` desabilitada no `.tflint.hcl`
  raiz (documentada) para não voltar a bloquear o CI por causa disso.
  Resolvido em 2026-07-13 — branch `fix/revert-vm-size-quota`.
- [ ] **Pedir aumento de cota `standardBsv2Family` no portal Azure** — só
  depois disso faz sentido tentar de novo a migração para
  `Standard_B2ts_v2` (ou outro tamanho da família Bsv2/Basv2). Sem prazo
  definido; revisitar a regra desabilitada no `.tflint.hcl` quando a cota
  for aprovada.
- [ ] **Triagem completa de findings Trivy** — `trivy.yaml` (raiz) roda em
  modo não-bloqueante (`exit-code: 0`). A narrativa anterior de "só 2
  achados" estava incompleta: o `trivy` CLI só respeita `--exit-code`
  quando a flag é passada explicitamente, então a suprimida `AZU-0047` nunca
  foi realmente testada sob falha — e o ID usado no `.trivyignore` estava
  **errado** (`AZU-0047` em vez do real `AVD-AZU-0047`; mesmo tipo de erro
  silencioso do episódio `misconfiguration.skip-check`, dessa vez mascarado
  pelo `exit-code: 0` do job). ID corrigido em 2026-07-13
  (`chore/flip-tflint-trivy-blocking`), e `AVD-AWS-0054` (que já usava o
  prefixo certo) confirmado suprimido de verdade.
  Rodando `trivy config . --exit-code 1` (scan completo do repo, não só o
  módulo isolado) aparecem **~39 findings reais adicionais**, não cobertos
  pela triagem original: 12 CRITICAL de SG com ingress público, 9 CRITICAL
  de SG com egress público amplo, 6 HIGH de subnet com IP público associado,
  3 HIGH de ALB sem `drop_invalid_header_fields`/exposto publicamente
  (`AVD-AWS-0052`/`0053`, já sabidos, fora de escopo da supressão do
  listener HTTP), achados de S3 sem public access block (4), bucket sem
  criptografia com chave gerenciada pelo cliente, e TLS antigo em Storage
  Account Azure. Precisa de uma rodada de triagem própria, caso a caso
  (corrigir vs. aceitar como risco de ambiente efêmero de demo), antes de
  virar bloqueante.
- [x] **Flipar tflint para bloqueante** — removido `continue-on-error: true`
  do job `tflint` em `.github/workflows/pr-validate.yml`, validado
  localmente que os 12 módulos da matrix passam limpo, e confirmado verde no
  CI real do PR. Resolvido em 2026-07-13 — branch
  `chore/flip-tflint-trivy-blocking`.
- [ ] **Flipar Trivy para bloqueante** — depende da triagem completa acima;
  tentativa neste PR foi revertida (`exit-code` voltou de `'1'` para `'0'`)
  ao descobrir o escopo real de ~39 findings.
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
