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

### 17. Pipeline de CI travava no `terraform apply` pedindo input interativo (regressão do item 1)
- [x] **Status:** resolvido
- **Tipo:** fix / regression
- **Local:** `environments/{aws,azure}/{teste,homol,prod}/variables.tf`,
  `.github/workflows/main.yml`
- **Problema:** Efeito colateral não tratado da remediação do item #1. Antes daquela
  correção, os 6 `terraform.tfvars` reais estavam commitados no Git, e o CI funcionava
  porque o Terraform carregava esses valores automaticamente do checkout. Ao remover
  esses arquivos do histórico (correção correta de segurança), ninguém repôs os valores
  por outro canal no pipeline. Resultado: qualquer variável sem `default`
  (`environment_name`, `vpc_cidr_block`/`vnet_cidr_block`, `instance_type`, `my_ip` no
  AWS; `vnet_cidr_block`, `my_ip`, `public_key` no Azure) travava o `terraform apply` no
  runner do GitHub Actions esperando input interativo que nunca chega (sem TTY),
  prendendo o job indefinidamente e segurando o state lock.
- **Impacto:** Pipeline de `apply`/`plan` completamente inoperante em qualquer ambiente
  desde a correção do item #1; runs presos consomem minutos de runner e podem deixar o
  state lock preso no DynamoDB, exigindo `force-unlock` manual.
- **Commit:** `1abf049`/`fc06e8d`/`2d1a6fa` (defaults AWS teste/homol/prod),
  `19dcd2b`/`180e873`/`d2cef11` (defaults Azure teste/homol/prod), `7864357`
  (secrets no workflow)
- **Notas:** Correção em duas frentes, conforme decisão do usuário: (1) valores não
  sensíveis (`environment_name`, `vpc_cidr_block`/`vnet_cidr_block`, `instance_type`)
  viraram `default` versionado direto no `variables.tf` de cada ambiente, usando os
  mesmos valores já documentados nos `.tfvars.example`; (2) `my_ip` (o próprio IP
  residencial que vazou no incidente do item #1) e `public_key` (chave SSH pública do
  bastion Azure) passaram a ser supridos via GitHub Secrets (`MY_IP`,
  `AZURE_BASTION_PUBLIC_KEY`), injetados como `TF_VAR_my_ip`/`TF_VAR_public_key` no
  bloco `env:` do workflow — exige criação manual desses 2 secrets no repo antes do
  próximo apply. `cloudflare_api_token`/`cloudflare_zone_id` já eram supridos
  corretamente e não precisaram de mudança; `key_name` do AWS já tinha `default`.
  `terraform validate` passou nos 6 ambientes após a mudança.
  **Achado adicional, também corrigido:** `environments/azure/{homol,prod}/variables.tf`
  tinham `default = "teste"` para `environment_name` (copiado do ambiente de teste e
  nunca ajustado). Corrigido para `"homol"`/`"prod"` respectivamente (commits
  `3aad4b2`/`5bd05d8`), a pedido do usuário após o teste real do pipeline ter travado
  justamente no ambiente Azure.

### 18. `lb_dns_name` com o mesmo bug de copy-paste do item 17, causando colisão de registro DNS na Cloudflare
- [x] **Status:** resolvido
- **Tipo:** fix / regression
- **Local:** `environments/azure/{homol,prod}/variables.tf`, `.github/workflows/main.yml`
- **Problema:** Mesma classe de bug do item #17 (`environment_name`), mas na variável
  irmã `lb_dns_name`: `environments/azure/{homol,prod}/variables.tf` tinham
  `default = "teste"` (copiado do ambiente teste e nunca ajustado), e o CI não passava
  `-var`/`TF_VAR_` para essa variável. Ao aplicar o ambiente `homol` pela primeira vez
  após a correção do item 17, o Terraform caiu nesse default e criou o registro
  Cloudflare `name = "${var.lb_dns_name}-azure"` como `teste-azure` em vez de
  `homol-azure` (`environments/azure/homol/dns.tf:10`).
- **Impacto:** Confirmado na prática pelo usuário: `homol-azure.alissonlima.dev.br`
  retornava `DNS_PROBE_FINISHED_NXDOMAIN` (registro nunca criado com o nome certo),
  enquanto `teste-azure.alissonlima.dev.br` continuou resolvendo mesmo após o ambiente
  teste ter sido destruído — prova de que aquele registro pertencia, na verdade, ao
  estado do homol. Corrigido o teste: destruir homol fez `teste-azure` parar de
  resolver, confirmando a colisão de nome entre os dois estados Terraform na mesma
  zona Cloudflare.
- **Commit:** `3374dd4` (default homol), `a0bff1a` (default prod), `5dc5464`
  (`-var` explícito no workflow)
- **Notas:** Duas frentes de correção: (1) `lb_dns_name` default corrigido para
  `"homol"`/`"prod"` em cada `variables.tf`; (2) causa raiz mais profunda endereçada no
  workflow — o step "Terraform Action" (jobs `terraform_azure` e `terraform_aws`) agora
  passa `-var="environment_name=${{ github.event.inputs.environment }}"` explicitamente
  (e `-var="lb_dns_name=..."` só no job Azure), usando o próprio input do workflow como
  fonte de verdade, em vez de depender de defaults locais que já erraram duas vezes
  seguidas. `terraform validate` passou em homol/prod após o fix; YAML do workflow
  validado com `python3 -c "import yaml; yaml.safe_load(...)"`.

### 19. `app_server_count` de prod caía no default (1) em vez do valor pretendido (2) via CI
- [x] **Status:** resolvido
- **Tipo:** fix / regression
- **Local:** `environments/{aws,azure}/prod/variables.tf`
- **Problema:** Mesma causa raiz dos itens 17/18: o valor real pretendido para prod
  (`app_server_count = 2`, para simular escala do web-server) só existia no
  `terraform.tfvars` local (gitignored, removido do Git no item #1) — `variables.tf`
  tinha `default = 1` em todos os ambientes (AWS e Azure), e o CI nunca passa essa
  variável via `-var`/`TF_VAR_`. Resultado: rodando via pipeline, prod caía no mesmo
  default `1` de teste/homol, em vez de escalar para 2 app servers.
- **Impacto:** Confirmado na prática pelo usuário: prod criava a mesma quantidade de
  recursos que teste/homol (38 na Azure, 40 na AWS) em vez dos recursos extras
  esperados para a escala de produção.
- **Commit:** `d68a032` (AWS prod), `6ec9866` (Azure prod)
- **Notas:** Corrigido apenas o `default` de `app_server_count` para `2` em
  `environments/aws/prod/variables.tf` e `environments/azure/prod/variables.tf`
  (teste/homol permanecem em `1`, valor correto) — mesmo padrão de tratamento já usado
  para `environment_name`/`vpc_cidr_block`/`instance_type` no item 17: valor não
  sensível, seguro como default versionado, sem precisar de `-var` explícito no
  workflow (diferente de `environment_name`/`lb_dns_name`, que são diretamente
  deriváveis do input do workflow — `app_server_count` não é). `terraform validate`
  passou em `aws/prod` e `azure/prod` após a mudança.
  **Achado relacionado, fora de escopo:** `environments/aws/teste/main.tf` e
  `environments/aws/homol/main.tf` não repassam `var.app_server_count` para o módulo
  `app_environment` (já documentado no item #6) — não afeta esta correção porque o
  default do módulo já é `1`, igual ao pretendido para teste/homol, mas fica registrado
  como dívida técnica pendente de limpeza.

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
- [x] **Status:** resolvido
- **Tipo:** best-practice
- **Local:** `ansible/templates/index.html.j2`
- **Problema:** Página carrega recursos externos em runtime.
- **Impacto:** Mínimo; dependência de disponibilidade externa.
- **Commit:** `14fce2e`
- **Notas:** O Jinja só renderiza o HTML no servidor — as duas chamadas externas
  (`cdn.tailwindcss.com`, `fonts.googleapis.com`) aconteciam no navegador de quem
  acessa a página, a cada carregamento. Dois motivos concretos para corrigir, dado o
  contexto do projeto (infra "liga/desliga", só sobe para teste/demo à banca): (1) o
  Tailwind CDN é um compilador JIT em JavaScript que a própria documentação do
  Tailwind recomenda usar só para prototipagem, nunca em nada que será de fato
  mostrado; (2) a instituição de ensino do usuário já bloqueia CDNs externos por
  firewall em outras ocasiões — rodar exatamente no momento da demonstração à banca
  seria o pior momento possível para essa falha se manifestar. Substituídas as
  classes utilitárias do Tailwind por CSS puro equivalente (mesmo `<style>` que já
  existia no arquivo) e a fonte Google Fonts por uma system font stack
  (`-apple-system, Segoe UI, Roboto, ...`, já presente em qualquer SO). Página
  renderizada localmente via Jinja2 (fora de qualquer infra/Ansible real, com
  variáveis fictícias para `azure` e `aws`) para conferir ausência de erros de
  sintaxe e equivalência visual antes do commit — não há navegador disponível nesta
  sessão para captura de tela, então a inspeção foi via leitura do HTML renderizado.

### 15. `docker-compose` v2.27.0 fixado via download manual do GitHub
- [x] **Status:** resolvido
- **Tipo:** obsolescence
- **Local:** `ansible/playbook_docker.yml`
- **Problema:** Já reconhecido no comentário do próprio playbook; duplica o mecanismo
  do plugin oficial já instalado via `apt`.
- **Impacto:** Potencial desatualização e duplicação de mecanismo de instalação.
- **Commit:** `866d204`
- **Notas:** O repositório oficial do Docker (`download.docker.com/linux/ubuntu`) já
  estava configurado para `docker-ce`/`docker-ce-cli`/`containerd.io`, mas o Compose
  v2 continuava fixado manualmente via `get_url` direto de uma release do GitHub
  (v2.27.0), com o próprio playbook reconhecendo em comentário que a versão
  precisava ser conferida manualmente. Substituído por `docker-compose-plugin`, pacote
  oficial do mesmo repo já em uso — instalado e atualizado pelo `apt` junto com o
  Engine, sem mecanismo duplicado. Confirmado por grep que nenhum outro
  script/playbook do repositório invoca o binário standalone `docker-compose`
  (hífen), então a migração para o subcomando `docker compose` (plugin, sem hífen)
  não quebra nada. `ansible-playbook --syntax-check` passou.

### 16. `disable_api_termination = false` em prod
- [x] **Status:** aceito (risco documentado, comportamento inalterado)
- **Tipo:** best-practice
- **Local:** `modules/aws/app_environment/main.tf`
- **Problema:** Confirmar se é intencional também para prod (padrão do TCC é permitir
  destroy total via pipeline).
- **Impacto:** Baixo risco de destruição acidental de prod sem camada extra de proteção.
- **Commit:** — (nenhuma mudança de Terraform; apenas esta entrada do checklist)
- **Notas:** Confirmado com o usuário: é intencional. O projeto é um TCC acadêmico
  com design de infra "liga/desliga" (toggle `create_environment`, ver `CLAUDE.md`)
  — nenhum ambiente, incluindo prod, roda 24/7, e o objetivo central do framework é
  permitir destruir qualquer ambiente via pipeline sem exceção, para economizar
  custo entre usos de teste/demonstração à banca. Adicionar `disable_api_termination
  = true` só em prod exigiria uma etapa manual extra (desligar a proteção antes de
  poder destruir), quebrando o fluxo 100% automatizado justamente no ambiente que
  precisa ser destruído com a mesma frequência dos demais. Decisão consciente:
  manter `false` em todos os ambientes, sem exceção — mesmo padrão de aceitação
  consciente já usado nos itens 4 e 10.

---

## Resumo por severidade

| Severidade | Qtd | Resolvidos | Aceitos |
|---|---|---|---|
| Crítico | 4 | 4 | 0 |
| Alto | 5 | 4 | 1 |
| Médio | 7 | 6 | 1 |
| Baixo | 3 | 2 | 1 |
