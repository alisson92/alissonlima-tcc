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
- [x] = resolvido ou aceito (ver campo **Status** de cada item para distinguir
  "resolvido" de "aceito" — aceito significa que o código não mudou, é um risco
  avaliado e assumido conscientemente)

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
     Segunda passada com `--replace-text` redigiu o IP real (substituído por
     `REDACTED_IP`) que
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
- [x] **Status:** resolvido
- **Tipo:** security
- **Local:** `modules/aws/bastion/main.tf`, `modules/aws/app_environment/main.tf`, `modules/aws/data_storage/main.tf`
- **Problema:** Nenhum `aws_ebs_volume`/`root_block_device` definia `encrypted = true`.
- **Impacto:** Dados do DB e demais volumes em texto plano em repouso.
- **Commit:** `f95e73a` (bastion), `cd50f13` (app_environment: app_server + db_server), `3350ef9` (data_storage)
- **Notas:** Adicionado `encrypted = true` em todos os `root_block_device` (bastion,
  app_server, db_server) e no `aws_ebs_volume.db_data`, usando a chave KMS gerenciada
  padrão da AWS (`alias/aws/ebs`, implícita — sem `kms_key_id` customizado). Azure não
  precisou de alteração: managed disks já são criptografados por padrão pela
  plataforma. **Atenção ao aplicar em ambientes já provisionados:** mudar `encrypted`
  força replacement do disco (destroy + create), então o próximo `apply` em
  teste/homol/prod vai recriar essas instâncias/volumes.

### 3. NSG do ALB (Azure) sem associação de subnet (regra morta)
- [x] **Status:** resolvido
- **Tipo:** best-practice / refactor
- **Local:** `modules/azure/security/main.tf`, `modules/azure/security/outputs.tf`
- **Problema:** `azurerm_network_security_group.alb` era criado mas nunca associado a
  nenhuma subnet.
- **Impacto:** Falsa sensação de segurança; recurso órfão gerando confusão.
- **Commit:** `14d828e` (remove o NSG e as regras), `b58bac1` (remove o output `nsg_alb_id`)
- **Notas:** Investigação mostrou que isso não era um "esqueceram de associar" —
  é estrutural: o `azurerm_lb` usado aqui é SKU Standard com IP público direto, que
  não fica dentro de nenhuma subnet (diferente do ALB da AWS). Não existe traffic
  path real que passe pela subnet candidata (`public_b`, que está vazia). A proteção
  de fato do tráfego HTTP nas VMs já é feita pelo NSG `application`
  (`AllowHTTPInbound` + `AllowAzureLoadBalancerProbe`), corretamente associado às
  subnets privadas. Decisão do usuário: remover o recurso órfão em vez de forçar uma
  associação cosmética sem efeito real de proteção.
  **Novo achado (fora do escopo deste item, para avaliação futura):** a subnet
  `azurerm_subnet.public_b` (`modules/azure/networking/main.tf`) ficou sem nenhum
  uso após esta remoção — nunca teve NIC, LB ou NSG associado. Candidata a um novo
  item de limpeza (remover a subnet ou documentar por que ela existe) se o usuário
  quiser tratar depois.

### 4. NSG da aplicação (Azure) libera porta 80 para `"*"` em subnet privada
- [x] **Status:** aceito (risco documentado, comportamento inalterado)
- **Tipo:** security
- **Local:** `modules/azure/security/main.tf` (regra `AllowHTTPInbound` do NSG `application`)
- **Problema:** Usa `source_address_prefix = "*"` em vez de escopar para a subnet do LB
  ou `VirtualNetwork`.
- **Impacto:** Amplia superfície de ataque desnecessariamente.
- **Commit:** `da67292` (apenas documentação/comentário — nenhum valor de Terraform mudou)
- **Notas:** Traffic path investigado e confirmado: cliente → Cloudflare (proxied,
  TLS termina lá) → nova conexão HTTP da borda da Cloudflare para o IP público do
  Azure LB → Standard LB preserva o IP de origem no caminho de entrada (sem SNAT) →
  o NSG na subnet da VM enxerga o IP da Cloudflare, que é externo à VNet. Por isso
  `"VirtualNetwork"` quebraria o acesso público real. A correção completa seria
  restringir `source_address_prefixes` às faixas de IP publicadas pela Cloudflare
  (cloudflare.com/ips) — **decisão do usuário: adiar essa mudança** para não
  introduzir a dependência de manter essa lista atualizada, já que Cloudflare + WAF
  já filtram boa parte do tráfego malicioso antes do origin. Documentado inline no
  código para deixar claro que é uma decisão consciente, não um descuido.

### 5. Provider `azurerm` travado em `~> 3.0` (major desatualizada)
- [x] **Status:** resolvido
- **Tipo:** obsolescence
- **Local:** `backend/azure/main.tf`, `environments/azure/*/versions.tf`
- **Problema:** Major 4.x disponível há tempo; v3 não recebia mais correções recentes.
- **Impacto:** Risco de fim de suporte; migração fica mais dolorosa quanto mais adiada.
- **Commit:** `536eacc` (backend), `f996286` (teste), `77126d8` (homol), `ca68b0e` (prod)
- **Notas:** Atualizado para `~> 4.80.0` (versão mais recente resolvida via
  `terraform init -upgrade` no momento da correção), no mesmo estilo de pin de
  patch já usado para o provider AWS (`~> 5.80.0`). Levantamento de todos os
  `azurerm_*` usados no projeto não encontrou nenhum recurso com mudança de schema
  quebradora conhecida entre v3→v4. A principal mudança de comportamento do v4
  (provider só registra um conjunto "core" de Resource Providers do Azure por
  padrão, em vez de registrar tudo como o v3) não deve afetar este projeto, já que
  a subscription já provisiona esses tipos de recurso há tempo (registro de RP é
  estado da subscription, não da versão do provider). `terraform validate` passou
  nos 3 ambientes e no `backend/azure` com o provider novo.
  **Atenção antes de aplicar em ambientes reais:** esta sessão não tinha
  credenciais Azure, então não foi possível rodar `terraform plan` contra a
  infraestrutura existente. Recomendado rodar `terraform plan` (sem apply) em
  `teste` primeiro para conferir que não há diffs inesperados do upgrade de major,
  antes de aplicar em `homol`/`prod`.

### 6. AMI AWS hardcoded sem mecanismo de atualização
- [x] **Status:** resolvido
- **Tipo:** obsolescence
- **Local:** `environments/aws/*/main.tf`, `environments/aws/*/variables.tf`,
  `environments/aws/*/terraform.tfvars.example`
- **Problema:** ID fixo (`ami-0a7d80731ae1b2435`) repetido em 5 lugares, sem
  `data "aws_ami"` com filtro.
- **Impacto:** AMI pode ser desregistrada pela AWS a qualquer momento; sem patches
  automáticos do SO.
- **Commit:** `1f969af`/`cade127`/`80140c6` (teste), `01187c9`/`f615aa2`/`1b48484`
  (homol), `33f45d9`/`b257e01`/`584d02e` (prod)
- **Notas:** Achado adicional durante a correção: os 3 `main.tf` já **ignoravam**
  a variável `ami_id` — hardcodavam o literal direto, mesmo com a variável
  declarada em `variables.tf` e valor em `terraform.tfvars`. Ou seja, além de
  obsolescência havia uma variável morta.
  Decisão do usuário: usar **sempre a AMI Ubuntu 22.04 LTS mais recente** via
  `data "aws_ami"` (owner Canonical, `most_recent = true`), sem manter override
  fixo opcional — mais simples, sempre atualizado. A variável `ami_id` foi
  removida por completo (`variables.tf`, `terraform.tfvars` locais e
  `.tfvars.example`, nos 3 ambientes).
  **Trade-off aceito conscientemente:** como data sources são reavaliados a cada
  `plan`/`apply`, se a Canonical publicar uma imagem 22.04 mais nova entre um
  apply e outro, o Terraform vai propor recriar as instâncias mesmo sem nenhuma
  mudança de código — o ambiente deixa de ser 100% pinado/reprodutível.
  `terraform validate` passou nos 3 ambientes após a mudança.
  **Novo achado, fora de escopo:** `environments/aws/teste/main.tf` e
  `environments/aws/homol/main.tf` não repassam `app_server_count` para o módulo
  `app_environment` (só `prod/main.tf` repassa) — provavelmente sempre usa o
  default do módulo. Candidato a um novo item de revisão, não tratado aqui.

---

## 🟡 Médio

### 7. Repositório Docker aponta para `focal` em hosts `jammy`
- [x] **Status:** resolvido
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** `apt_repository` usava `focal` (Ubuntu 20.04) enquanto os hosts rodam
  22.04 "jammy".
- **Impacto:** Funcionava por acaso; não era garantido em atualizações futuras do repo Docker.
- **Commit:** `7672f11`
- **Notas:** Em vez de trocar o literal fixo `focal` por `jammy` (resolveria só o
  sintoma atual e reintroduziria o mesmo problema numa futura migração de distro),
  usado o fact dinâmico `{{ ansible_distribution_release }}` — mesmo padrão que a
  documentação oficial do Docker recomenda (`$(lsb_release -cs)`). Resolve a causa
  raiz: o codename correto é sempre derivado do host real. `ansible-playbook
  --syntax-check` passou; confirmado que o playbook não desativa `gather_facts`.

### 8. Módulo `ansible.builtin.apt_key` deprecated
- [x] **Status:** resolvido
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** `apt_key` era deprecated; caminho recomendado é keyring em
  `/etc/apt/keyrings/` + `signed-by`.
- **Impacto:** Dívida técnica que tenderia a quebrar em versões futuras.
- **Commit:** `7140e12`
- **Notas:** Chave GPG do Docker agora baixada para `/etc/apt/keyrings/docker.asc`
  (via `ansible.builtin.get_url`, sem precisar de `gpg --dearmor` — o `apt` do
  Ubuntu 22.04 aceita `signed-by` apontando direto para um `.asc` armored, mesmo
  padrão que a documentação oficial do Docker usa hoje) e referenciada via
  `signed-by=` na linha do `apt_repository`. Nenhuma coleção externa foi
  necessária, só módulos `ansible.builtin.*` já usados no resto do playbook.
  `ansible-playbook --syntax-check` passou; `grep -rn "apt_key" ansible/` ficou
  vazio.

### 9. Imagem `nginx:latest` (tag mutável)
- [x] **Status:** resolvido
- **Tipo:** best-practice
- **Local:** `ansible/playbook_nginx_container.yml`
- **Problema:** Gatilho de alerta próprio do usuário (evitar tag `latest`).
- **Impacto:** Builds não reprodutíveis.
- **Commit:** `0f2e886`
- **Notas:** Consultada a API pública do Docker Hub
  (`hub.docker.com/v2/repositories/library/nginx/tags`) em 2026-07-06 para saber o
  que `latest` resolvia naquele momento: `latest` e `mainline` apontavam para o
  mesmo digest (versão `1.31.2`, branch mainline/desenvolvimento), enquanto `stable`
  apontava para outro digest (versão `1.30.3`, branch stable). Ou seja,
  `nginx:latest` na prática seguia a branch mainline, não a stable. Pinado para
  `nginx:1.30.3` (branch stable, mesmo flavor Debian já em uso — não trocado para
  `-alpine`, que mudaria o flavor da imagem além do escopo deste item).
  **Atenção:** como é uma versão fixa, precisará de atualização manual periódica
  (não há automação de bump de versão de imagem neste projeto).

### 10. Ausência de VPC Flow Logs / NSG Flow Logs
- [x] **Status:** aceito (adiado, comportamento inalterado)
- **Tipo:** best-practice
- **Local:** `modules/aws/networking/`, `modules/azure/networking/`
- **Problema:** Nenhum `aws_flow_log` nem Network Watcher flow logs configurado —
  os Security Groups/NSGs decidem allow/deny mas não guardam nenhum registro dessas
  decisões, então não há trilha de auditoria para investigar tráfego suspeito ou
  tentativas de acesso indevido.
- **Impacto:** Sem trilha de auditoria de rede para investigação de incidentes.
- **Commit:** — (nenhuma mudança de infraestrutura)
- **Notas:** Discutido com o usuário o que a correção envolveria: na AWS,
  `aws_flow_log` + um CloudWatch Log Group + uma IAM Role para o serviço de flow
  logs publicar nele; na Azure, o recurso `azurerm_network_watcher_flow_log`
  (confirmado via `terraform providers schema` no provider `azurerm ~> 4.80.0`)
  usando `target_resource_id` apontando para a VNet — **não**
  `network_security_group_id` (NSG Flow Log clássico), já que esse recurso legado
  tem fim de suporte anunciado pela Microsoft; VNet Flow Log é o caminho
  recomendado hoje. Em ambos os casos seria necessário criar recursos novos
  (destino de armazenamento + permissões) em cada um dos 3 ambientes × 2 clouds.
  **Decisão do usuário: adiar esta correção por ora** — é um projeto acadêmico
  (TCC) e o custo/complexidade adicional (armazenamento de logs, IAM, Network
  Watcher) não se justifica no momento. Se implementado no futuro, os pontos de
  decisão a resolver são: tipo de tráfego capturado (`ALL` vs `REJECT`-only, mais
  barato e focado em tentativas bloqueadas) e período de retenção dos logs.

### 11. Sem enforcement de IMDSv2 nas instâncias EC2
- [x] **Status:** resolvido
- **Tipo:** security
- **Local:** `modules/aws/bastion/main.tf`, `modules/aws/app_environment/main.tf`
- **Problema:** Ausência de `metadata_options { http_tokens = "required" }`.
- **Impacto:** Superfície de SSRF que captura credenciais de instance profile via IMDSv1.
- **Commit:** `e7494ca` (bastion), `afd8012` (app_environment: app_server + db_server)
- **Notas:** Adicionado bloco `metadata_options` nas 3 instâncias (`bastion_host`,
  `app_server`, `db_server`) com `http_tokens = "required"` (força IMDSv2,
  desativando IMDSv1 que não exige token) e `http_put_response_hop_limit = 1`
  (limite padrão da AWS, deixado explícito por clareza — relevante aqui porque as
  instâncias rodam Docker, e um hop limit maior permitiria que containers também
  acessassem o metadata service). `http_endpoint = "enabled"` mantém o serviço
  disponível, já que nada no Ansible depende de acesso irrestrito via IMDSv1.
  `terraform validate` passou em `environments/aws/teste`. Mudança é update
  in-place (não força replacement de instância), mas mesmo assim recomenda-se
  `terraform plan` antes de aplicar em ambientes já provisionados.

### 12. `required_version` do Terraform inconsistente
- [x] **Status:** resolvido
- **Tipo:** refactor / best-practice
- **Local:** `backend/azure/main.tf` (`>= 1.0.0`) vs. resto do projeto (`~> 1.12`)
- **Problema:** Bootstrap da Azure não segue o mesmo pin de versão dos ambientes.
- **Impacto:** Divergência silenciosa de versão do binário Terraform.
- **Commit:** `f8ca38a`
- **Notas:** Grep confirmou que `backend/azure/main.tf` era o único arquivo do
  projeto ainda usando `>= 1.0.0` — todos os `environments/*/versions.tf` e
  `backend/aws/main.tf` já usavam `~> 1.12`. Alinhado para o mesmo pin. Como
  `required_version` só afeta o binário CLI local (não gera diff de
  `plan`/`apply`), não há necessidade de validar contra infraestrutura real.

### 13. README desatualizado em relação à arquitetura atual
- [x] **Status:** resolvido
- **Tipo:** refactor / docs
- **Local:** `README.md`
- **Problema:** Menciona Route 53 como DNS público (é Cloudflare) e SSL no ALB (é
  terminado na Cloudflare); nome de workflow desatualizado; árvore de diretórios
  não lista `prod`.
- **Impacto:** Documentação incorreta sobre onde o TLS é terminado — relevante para
  banca de TCC.
- **Commit:** `e77daa2`
- **Notas:** Corrigidas 5 divergências: (1) README só descrevia AWS, sem qualquer
  menção a Azure, apesar do projeto ser explicitamente multi-cloud — reescrito para
  cobrir ambos e explicar que são implementações paralelas do mesmo desenho de 6
  módulos; (2) DNS público corrigido de "Route 53" para Cloudflare; (3) SSL/TLS
  corrigido: termina na Cloudflare, não no ALB; (4) nome do workflow corrigido de
  "Terraform TCC Pipeline" para `'Orquestrador Multicloud TCC (Azure & AWS)'`,
  passo-a-passo de uso atualizado com o input "Provedor de Nuvem" e a opção
  `force-unlock`; (5) árvore de diretórios atualizada para listar `prod` e toda a
  árvore `environments/azure/*` e `modules/azure/*`, além dos módulos
  `data_storage`, `app_environment`, `bastion`, `load_balancer` que faltavam em
  `modules/aws/*`. Badge visual do Azure também adicionado (fora do escopo original,
  aprovado à parte) para consistência com o texto atualizado.

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

| Severidade | Qtd | Resolvidos | Aceitos |
|---|---|---|---|
| Crítico | 1 | 1 | 0 |
| Alto | 5 | 4 | 1 |
| Médio | 7 | 6 | 1 |
| Baixo | 3 | 0 | 0 |
