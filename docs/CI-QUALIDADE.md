# Gates de Qualidade no Pipeline de PR (`pr-validate.yml`)

Este documento explica as 4 verificações automáticas de qualidade adicionadas ao
workflow `.github/workflows/pr-validate.yml` em julho de 2026: por que elas foram
criadas, o que cada uma faz, em que ferramentas de mercado nos baseamos e quais
decisões técnicas foram tomadas ao longo do caminho.

## Por que isso foi feito

Até então, todo PR contra `main`/`develop` passava por apenas duas verificações:
`terraform fmt -check` (formatação) e `terraform validate` (sintaxe/parsing). Isso
garantia que o código Terraform era sintaticamente válido, mas não garantia:

- **Boas práticas de HCL** — variáveis não usadas, saídas sem descrição, convenções
  de nomenclatura, providers não pinados.
- **Segurança de configuração** — Security Groups/NSGs abertos, recursos sem
  criptografia, listeners sem TLS, e outros riscos que hoje são checados apenas
  manualmente (ver os gatilhos de alerta already seguidos neste projeto: SG com
  `*`, ausência de `resources.limits`, secrets em texto plano, etc.).
- **Comportamento funcional dos módulos** — nada impedia que uma mudança em
  `main.tf` quebrasse silenciosamente um invariante arquitetural (por exemplo, uma
  regra de Security Group passar a referenciar um CIDR aberto em vez do SG de
  origem por ID) sem que ninguém percebesse até a próxima aplicação real.
- **Sincronismo da documentação** — os `README.md` de cada módulo são gerados por
  `terraform-docs` a partir de `variables.tf`/`outputs.tf`, mas nada os
  regenerava/validava em CI; um `variables.tf` alterado sem rodar `terraform-docs`
  localmente ficaria dessincronizado sem ninguém notar.

O objetivo desta rodada foi fechar essas quatro lacunas usando ferramentas
padrão de mercado para Terraform em CI, mantendo o pipeline de PR **100% livre de
credenciais de nuvem** (nenhum job novo faz `terraform init` contra um backend
real ou chama APIs de nuvem — requisito importante porque este é um repositório
público e PRs podem, em teoria, vir de forks).

## O que foi feito

Quatro jobs novos foram adicionados a `pr-validate.yml`, além dos já existentes
`fmt` e `validate`:

### 1. `tflint` — Lint de boas práticas HCL

**Config:** `.tflint.hcl` na raiz do repositório.

Carrega três plugins num único arquivo:
- `plugin "terraform"` (preset `all`) — regras genéricas de Terraform (variáveis
  não usadas, nomenclatura, sintaxe depreciada).
- `plugin "aws"` (`tflint-ruleset-aws`) — regras específicas de recursos AWS.
- `plugin "azurerm"` (`tflint-ruleset-azurerm`) — regras específicas de recursos
  Azure.

**Por que um único config em vez de dois (um por provider)?** Este projeto segue
o princípio de "paridade de provider, não código compartilhado" — `modules/aws/*`
e `modules/azure/*` são implementações paralelas e independentes. Isso vale para
*código de módulo*, mas não necessariamente para *configuração de ferramenta*:
cada plugin do tflint só dispara em recursos do seu próprio tipo (`aws_*` ou
`azurerm_*`), então carregar os dois plugins simultaneamente não gera ruído
cruzado entre as árvores AWS e Azure. Um arquivo único é mais simples de manter
(uma bump de versão em vez de duas configs quase-duplicadas sincronizadas
manualmente).

**Execução:** matrix nos 12 diretórios de módulo (não nos 6 diretórios de
ambiente — a composição já é validada pelo job `validate`).

**Status inicial:** `continue-on-error: true` (não-bloqueante). A primeira
execução completa já encontrou findings reais e legítimos pré-existentes (por
exemplo, `outputs.tf` sem `description` em alguns módulos Azure) — como isso não
tinha sido corrigido/triado ainda, tornar o job bloqueante no dia 1 travaria
todo PR futuro por um problema pré-existente, não introduzido pela mudança em
si. A intenção é corrigir/suprimir esses achados (com justificativa) numa
rodada de triagem e só então remover o `continue-on-error`.

### 2. `trivy` — Scan de segurança de configuração (Infrastructure as Code)

**Config:** `trivy.yaml` na raiz.

A escolha original de ferramenta, discutida com o usuário, foi o **tfsec**
(`aquasecurity/tfsec`), um scanner de segurança consolidado no ecossistema
Terraform. Durante a implementação, porém, identificamos que **o próprio README
do tfsec recomenda migrar para o Trivy**: a Aqua Security (mantenedora de ambos)
consolidou o desenvolvimento ativo no Trivy, mantendo o tfsec disponível mas sem
receber mais atenção de engenharia. Como o Trivy usa o mesmo motor de scan
Terraform, a troca foi feita sem perda de cobertura e com garantia de manutenção
de longo prazo — importante para um projeto que deve continuar em uso após a
apresentação do TCC.

Supressões justificadas de findings específicos são feitas via `.trivyignore`
(raiz do repo, descoberto automaticamente pelo Trivy), um ID por linha com o
motivo em comentário — **não** via `trivy.yaml` (a chave
`misconfiguration.skip-check`, usada numa primeira tentativa, não existe no
schema do Trivy 0.70 e é ignorada silenciosamente, sem suprimir nada).

**Execução:** um único job (não matrix — o `trivy config` varre recursivamente
`modules/` e `environments/` numa só chamada), com upload do relatório em
formato SARIF para a aba *Security* do GitHub.

**Status inicial:** `exit-code: 0` (não-bloqueante). Encontrou 2 achados reais
na primeira execução, ambos já formalmente suprimidos via `.trivyignore`:
- `AZU-0047` — NSG do app tier Azure com `source_address_prefix = "*"` —
  risco já aceito e documentado diretamente no `main.tf` (ver comentário no
  código, item #4 do `HARDENING_CHECKLIST.md`): o tráfego HTTP público
  legítimo chega a essa sub-rede privada vindo de fora da VNet (Cloudflare →
  LB → app), então restringir para `VirtualNetwork` quebraria o acesso real.
- `AVD-AWS-0054` — Listener HTTP do ALB (AWS) sem HTTPS — intencional, já que
  o TLS termina na Cloudflare, não no Load Balancer (ver seção de DNS/
  arquitetura no `CLAUDE.md`).

Ambos os achados já eram comportamentos conscientes e documentados no código —
o scanner apenas os tornou visíveis de forma automatizada. A triagem consistiu
em formalizar essas exceções no `.trivyignore` com a justificativa, em vez de
deixar o job falhando indefinidamente.

### 3. `terraform-docs-check` — Verificação de sincronismo dos READMEs

**Config:** reaproveita o `.terraform-docs.yml` já existente na raiz (nenhuma
config nova).

O job roda o binário `terraform-docs` em modo `inject` (mesmo modo já usado para
gerar os `README.md` de cada módulo) e depois faz `git diff --exit-code` no
arquivo gerado. Se o README commitado divergir do que seria gerado a partir do
`variables.tf`/`outputs.tf` atual, o PR falha.

**Descoberta durante a implementação:** a alternativa mais "pronta" para isso
seria usar a GitHub Action oficial `terraform-docs/gh-actions`, que embrulha o
`terraform-docs` numa imagem Docker. Na primeira execução em CI, **todos os 12
jobs falharam** com a mensagem `Uncommitted change(s) has been found!`, mesmo
com os READMEs comprovadamente sincronizados (validado localmente antes do
commit). A causa raiz: a imagem Docker daquela Action tem a versão do
`terraform-docs` **fixada em v0.20.0** no seu `Dockerfile`, enquanto os READMEs
haviam sido gerados/validados localmente com a v0.24.0 — as duas versões
formatam os separadores de tabela markdown de forma ligeiramente diferente
(`| ---- |` vs `|------|`), o que é puramente cosmético mas ainda assim conta
como "diff" para o `git diff --exit-code`.

A correção foi abandonar a Action wrapper e instalar o binário `terraform-docs`
diretamente no job (via `curl` num release oficial do GitHub, pinado
explicitamente em v0.24.0), garantindo que CI e geração local usem sempre a
mesma versão. **Lição registrada para o futuro:** ao adotar qualquer GitHub
Action que empacote uma ferramenta CLI dentro de uma imagem Docker própria,
vale a pena checar a versão da ferramenta fixada nessa imagem antes de assumir
que ela bate com o binário usado no ambiente de desenvolvimento local.

**Execução:** matrix nos 12 diretórios de módulo.

**Status inicial:** já bloqueante desde o primeiro merge. Diferente do
tflint/Trivy, um README dessincronizado não é um "achado legado" a ser triado —
é uma divergência real entre código e documentação que deveria sempre ser
corrigida antes do merge. Todos os 12 READMEs já estavam sincronizados no
momento da implementação, então não havia risco de travar PRs em andamento.

### 4. `terraform-test` — Testes funcionais dos módulos

**Novos arquivos:** 12 arquivos `.tftest.hcl`, um por módulo, em
`modules/<provider>/<modulo>/tests/main.tftest.hcl` — usando o framework nativo
de testes do Terraform (`terraform test`, disponível desde a versão 1.6+).

Cada arquivo usa `mock_provider "aws" {}` / `mock_provider "azurerm" {}`, que
simula as respostas do provider **sem fazer nenhuma chamada de API real e sem
exigir credenciais** — essencial para manter o pipeline de PR fork-safe. A
maioria dos testes roda com `command = plan`; alguns (onde o valor testado só é
conhecido após a criação do recurso, como um ID de recurso referenciado por
outro) precisam de `command = apply`, ainda contra o provider mockado.

**Ponto de maior valor do lote:** os testes de `modules/aws/security` e
`modules/azure/security` codificam diretamente, de forma automatizada, o
invariante de segurança já documentado no `CLAUDE.md` deste projeto — que
regras de Security Group/NSG entre bastion, load balancer e camada de aplicação
devem sempre referenciar a origem **por ID**, nunca por um CIDR aberto. Antes
desta mudança, esse invariante só existia como uma convenção seguida
manualmente pelo autor; agora, qualquer PR que o quebre falha automaticamente
no CI, com uma mensagem de erro explicando o motivo.

Os testes rodam contra os módulos diretamente (`modules/aws/networking`, por
exemplo), nunca contra os `environments/*/main.tf` de composição — isso evita
qualquer interação com o gate `count = var.create_environment ? 1 : 0` usado
para ligar/desligar ambientes inteiros, que vive uma camada acima dos módulos.

**Execução:** matrix nos 12 diretórios de módulo. Cada job faz
`terraform init -backend=false` (necessário mesmo com mock — o Terraform
precisa do *schema* do provider, não de credenciais reais) seguido de
`terraform test`.

**Status inicial:** já bloqueante desde o primeiro merge. Diferente do
tflint/Trivy, estes são testes novos, escritos especificamente para passar
contra o código atual dos módulos — não há achados legados de terceiros para
triar, então não havia motivo para começar como não-bloqueante.

## Em que nos baseamos

- **tflint** — [terraform-linters/tflint](https://github.com/terraform-linters/tflint)
  + rulesets oficiais [`tflint-ruleset-aws`](https://github.com/terraform-linters/tflint-ruleset-aws)
  e [`tflint-ruleset-azurerm`](https://github.com/terraform-linters/tflint-ruleset-azurerm).
- **Trivy** — [aquasecurity/trivy](https://github.com/aquasecurity/trivy), scanner
  de misconfiguration para Terraform mantido pela Aqua Security (sucessor
  recomendado do tfsec).
- **terraform-docs** — [terraform-docs/terraform-docs](https://github.com/terraform-docs/terraform-docs),
  já era usado neste projeto para gerar os READMEs de módulo; a novidade é
  apenas verificar o sincronismo em CI.
- **terraform test** — recurso nativo do próprio Terraform (HashiCorp), sem
  dependência de ferramenta externa, usando o bloco `mock_provider` introduzido
  para permitir testes sem credenciais de nuvem.

## O que ficou fora de escopo (adiado, não rejeitado)

- **Triagem dos achados do tflint e do Trivy** — corrigir ou suprimir (com
  justificativa) cada finding pré-existente, para então remover
  `continue-on-error`/mudar `exit-code` para `1` nesses dois jobs.
- **Tornar tflint/Trivy required status checks** no GitHub Ruleset que já
  protege `main`/`develop` — só faz sentido depois da triagem acima, senão o
  ruleset passaria a bloquear PRs por achados que ainda não foram avaliados.
- **Composite GitHub Action** para eliminar a duplicação dos passos
  checkout + setup-terraform + init, hoje repetidos em 5 jobs diferentes do
  workflow — decisão consciente de não introduzir essa abstração antes de os
  jobs atuais provarem estáveis em uso real, para evitar refatorar uma
  abstração prematura.
- **`terraform test` com `command = apply` completo** (em vez de misto
  plan/apply) — manteríamos os testes mais simples, sem precisar mockar cada
  atributo computado de cada recurso.

## Onde encontrar o código

- Workflow: [`.github/workflows/pr-validate.yml`](../.github/workflows/pr-validate.yml)
- Config do tflint: [`.tflint.hcl`](../.tflint.hcl)
- Config do Trivy: [`trivy.yaml`](../trivy.yaml)
- Config do terraform-docs (reaproveitado): [`.terraform-docs.yml`](../.terraform-docs.yml)
- Testes: `modules/<aws|azure>/<módulo>/tests/main.tftest.hcl`
