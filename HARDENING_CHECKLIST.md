# Checklist de Hardening e Limpeza do Projeto

> Documento de acompanhamento gerado a partir da varredura completa do repositório
> na branch `chore/project-hardening-and-cleanup`.
>
> Cada item deve virar **um commit separado**, seguindo Conventional Commits
> (`fix:`, `chore:`, `refactor:`, `security:`, `docs:` etc.), com nomenclatura técnica
> em inglês. Ao resolver um item, marque o checkbox, anote o commit/PR correspondente
> e a data.

## Status

- [ ] = pendente
- [x] = resolvido (preencher commit + data)

---

## 🔴 Crítico

### 1. `terraform.tfvars` versionado no Git em repositório público
- [x] **Status:** resolvido
- **Tipo:** security
- **Local:** `environments/{aws,azure}/{teste,homol,prod}/terraform.tfvars`
- **Problema:** `.gitignore` proíbe `*.tfvars`, mas os 6 arquivos estavam rastreados no Git,
  e o repositório `alisson92/alissonlima-tcc` é **público**. Expunha IP residencial real,
  chave SSH pública completa, `key_name` do AWS Key Pair (`tcc-alisson-key`) e AMI ID fixo.
- **Impacto:** Reconhecimento/engenharia social contra os ambientes prod; dados já
  estavam no histórico do Git (remover do working tree não bastava).
- **Commit:** histórico reescrito via `git filter-repo` (não é um único commit —
  todas as branches remotas tiveram os SHAs reescritos e foram `push --force`d);
  arquivos `.example` adicionados em `efac4e0`, `3eaf2b9`, `5201dd4`, `d83b330`,
  `2cc7f84`, `c5924c2`; ajuste do `.gitignore` em `1fa9d75`.
- **Notas:** Remediação em duas frentes:
  1. `git filter-repo --invert-paths` removeu os 6 `terraform.tfvars` de **todo o
     histórico**, em `main`, `develop` e `chore/project-hardening-and-cleanup`
     (os blobs são compartilhados entre branches, não dá para limpar só uma).
     Segunda passada com `--replace-text` redigiu o IP real (`REDACTED_IP`) que
     também aparecia hardcoded em commits antigos de `environments/aws/teste/main.tf`
     antes do refactor para variáveis, e neste próprio checklist.
  2. `git push --force --all origin` reescreveu o histórico remoto — qualquer
     clone/fork antigo fica dessincronizado e precisa ser re-clonado.
  3. Os 6 `terraform.tfvars` reais foram restaurados **localmente** (não
     versionados, cobertos pelo `.gitignore`) a partir de um backup feito antes da
     reescrita, para não quebrar o `plan`/`apply` local.
  4. Criados `terraform.tfvars.example` para os 6 ambientes com placeholders
     (`YOUR_IP_ADDRESS`, `ami-xxxxxxxxxxxxxxxxx`, `your-aws-key-pair-name`, chave
     SSH de exemplo), documentando as variáveis esperadas sem repetir dados reais.
  5. A chave SSH pública completa não precisou de redação adicional no histórico:
     conferido que ela só existia dentro dos próprios `terraform.tfvars` já
     removidos (0 ocorrências em outros arquivos/commits).
  6. `key_name` (`tcc-alisson-key`) e o AMI ID **não** foram redigidos do histórico
     — são apenas identificadores de recurso, não credenciais, e continuam
     presentes no código atual (`environments/aws/*/main.tf`) de forma legítima.

---

## 🟠 Alto

### 2. Discos EBS (AWS) sem criptografia em repouso
- [ ] **Status:** pendente
- **Tipo:** security
- **Local:** `modules/aws/app_environment/main.tf`, `modules/aws/data_storage/main.tf`
- **Problema:** Nenhum `aws_ebs_volume`/`root_block_device` define `encrypted = true`.
- **Impacto:** Dados do DB e demais volumes em texto plano em repouso.
- **Commit:** —
- **Notas:** —

### 3. NSG do ALB (Azure) sem associação de subnet (regra morta)
- [ ] **Status:** pendente
- **Tipo:** best-practice / refactor
- **Local:** `modules/azure/security/main.tf` (bloco comentado ~linhas 126-133)
- **Problema:** `azurerm_network_security_group.alb` é criado mas nunca associado a
  nenhuma subnet.
- **Impacto:** Falsa sensação de segurança; recurso órfão gerando confusão.
- **Commit:** —
- **Notas:** —

### 4. NSG da aplicação (Azure) libera porta 80 para `"*"` em subnet privada
- [ ] **Status:** pendente
- **Tipo:** security
- **Local:** `modules/azure/security/main.tf` (regra `AllowHTTPInbound` do NSG `application`)
- **Problema:** Usa `source_address_prefix = "*"` em vez de escopar para a subnet do LB
  ou `VirtualNetwork`.
- **Impacto:** Amplia superfície de ataque desnecessariamente.
- **Commit:** —
- **Notas:** —

### 5. Provider `azurerm` travado em `~> 3.0` (major desatualizada)
- [ ] **Status:** pendente
- **Tipo:** obsolescence
- **Local:** `backend/azure/main.tf`, `environments/azure/*/versions.tf`
- **Problema:** Major 4.x disponível há tempo; v3 não recebe mais correções recentes.
- **Impacto:** Risco de fim de suporte; migração fica mais dolorosa quanto mais adiada.
- **Commit:** —
- **Notas:** —

### 6. AMI AWS hardcoded sem mecanismo de atualização
- [ ] **Status:** pendente
- **Tipo:** obsolescence
- **Local:** `environments/aws/*/main.tf`, `environments/aws/*/variables.tf`
- **Problema:** ID fixo (`ami-0a7d80731ae1b2435`) repetido em 5 lugares, sem
  `data "aws_ami"` com filtro.
- **Impacto:** AMI pode ser desregistrada pela AWS a qualquer momento; sem patches
  automáticos do SO.
- **Commit:** —
- **Notas:** —

---

## 🟡 Médio

### 7. Repositório Docker aponta para `focal` em hosts `jammy`
- [ ] **Status:** pendente
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** `apt_repository` usa `focal` (Ubuntu 20.04) enquanto os hosts rodam
  22.04 "jammy".
- **Impacto:** Funciona por acaso hoje; não garantido em atualizações futuras do repo Docker.
- **Commit:** —
- **Notas:** —

### 8. Módulo `ansible.builtin.apt_key` deprecated
- [ ] **Status:** pendente
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** `apt_key` é deprecated; caminho recomendado é keyring em
  `/etc/apt/keyrings/` + `signed-by`.
- **Impacto:** Dívida técnica que tende a quebrar em versões futuras.
- **Commit:** —
- **Notas:** —

### 9. Imagem `nginx:latest` (tag mutável)
- [ ] **Status:** pendente
- **Tipo:** best-practice
- **Local:** `ansible/playbook_nginx_container.yml`
- **Problema:** Gatilho de alerta próprio do usuário (evitar tag `latest`).
- **Impacto:** Builds não reprodutíveis.
- **Commit:** —
- **Notas:** —

### 10. Ausência de VPC Flow Logs / NSG Flow Logs
- [ ] **Status:** pendente
- **Tipo:** best-practice
- **Local:** `modules/aws/networking/`, `modules/azure/networking/`
- **Problema:** Nenhum `aws_flow_log` nem Network Watcher flow logs configurado.
- **Impacto:** Sem trilha de auditoria de rede para investigação de incidentes.
- **Commit:** —
- **Notas:** —

### 11. Sem enforcement de IMDSv2 nas instâncias EC2
- [ ] **Status:** pendente
- **Tipo:** security
- **Local:** `modules/aws/bastion/main.tf`, `modules/aws/app_environment/main.tf`
- **Problema:** Ausência de `metadata_options { http_tokens = "required" }`.
- **Impacto:** Superfície de SSRF que captura credenciais de instance profile via IMDSv1.
- **Commit:** —
- **Notas:** —

### 12. `required_version` do Terraform inconsistente
- [ ] **Status:** pendente
- **Tipo:** refactor / best-practice
- **Local:** `backend/azure/main.tf` (`>= 1.0.0`) vs. resto do projeto (`~> 1.12`)
- **Problema:** Bootstrap da Azure não segue o mesmo pin de versão dos ambientes.
- **Impacto:** Divergência silenciosa de versão do binário Terraform.
- **Commit:** —
- **Notas:** —

### 13. README desatualizado em relação à arquitetura atual
- [ ] **Status:** pendente
- **Tipo:** refactor / docs
- **Local:** `README.md`
- **Problema:** Menciona Route 53 como DNS público (é Cloudflare) e SSL no ALB (é
  terminado na Cloudflare); nome de workflow desatualizado; árvore de diretórios
  não lista `prod`.
- **Impacto:** Documentação incorreta sobre onde o TLS é terminado — relevante para
  banca de TCC.
- **Commit:** —
- **Notas:** —

---

## 🟢 Baixo

### 14. CDN externo (Tailwind, Google Fonts) na página de status
- [ ] **Status:** pendente
- **Tipo:** best-practice
- **Local:** `ansible/templates/index.html.j2`
- **Problema:** Página carrega recursos externos em runtime.
- **Impacto:** Mínimo; dependência de disponibilidade externa.
- **Commit:** —
- **Notas:** —

### 15. `docker-compose` v2.27.0 fixado via download manual do GitHub
- [ ] **Status:** pendente
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** Já reconhecido no comentário do próprio playbook; duplica o mecanismo
  do plugin oficial já instalado via `apt`.
- **Impacto:** Potencial desatualização e duplicação de mecanismo de instalação.
- **Commit:** —
- **Notas:** —

### 16. `disable_api_termination = false` em prod
- [ ] **Status:** pendente
- **Tipo:** best-practice
- **Local:** `modules/aws/app_environment/main.tf`
- **Problema:** Confirmar se é intencional também para prod (padrão do TCC é permitir
  destroy total via pipeline).
- **Impacto:** Baixo risco de destruição acidental de prod sem camada extra de proteção.
- **Commit:** —
- **Notas:** —

---

## Resumo por severidade

| Severidade | Qtd | Resolvidos |
|---|---|---|
| Crítico | 1 | 1 |
| Alto | 5 | 0 |
| Médio | 7 | 0 |
| Baixo | 3 | 0 |
