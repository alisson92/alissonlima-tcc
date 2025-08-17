# Framework de Automação de Infraestrutura Multi-Cloud - TCC

**Um framework robusto, baseado em Infraestrutura como Código (IaC), para o provisionamento e configuração ágil e segura de ambientes de aplicação na nuvem.**

---

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Ansible](https://img.shields.io/badge/ansible-%231A1918.svg?style=for-the-badge&logo=ansible&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

## 📖 Resumo do Projeto

Este repositório contém o Trabalho de Conclusão de Curso (TCC) para o curso de Análise e Desenvolvimento de Sistemas da Fatec. O projeto ataca uma "dor" de mercado crítica: a lentidão, o custo elevado e a inconsistência associados ao provisionamento manual de infraestrutura de TI.

A solução é um framework de automação que utiliza as melhores práticas de mercado (DevOps, IaC) para criar ambientes de aplicação completos (Teste, Homologação e Produção) de forma 100% automatizada, garantindo agilidade, segurança e consistência entre eles.

## 🏛️ Arquitetura da Solução (AWS)

**Nota:** É altamente recomendável inserir aqui um diagrama visual da arquitetura.

A infraestrutura provisionada na AWS segue um design de alta disponibilidade e segurança, distribuída em múltiplas Zonas de Disponibilidade. Os componentes principais são:

* **Rede (VPC):** Uma VPC customizada com sub-redes públicas (para recursos de front-end como Load Balancer e Bastion Host) e privadas (para recursos de back-end como servidores de aplicação e banco de dados), garantindo o isolamento da camada de dados.
* **Computação (EC2):** A arquitetura é composta por instâncias EC2 para:
    * **Bastion Host:** Ponto de entrada seguro para acesso administrativo.
    * **Servidor de Aplicação:** Onde a aplicação principal é executada.
    * **Servidor de Banco de Dados:** Isalado na rede privada para máxima segurança.
* **Acesso e DNS (Route 53):** O Route 53 gerencia os nomes de DNS públicos (para a aplicação e o Bastion) e privados (para a comunicação interna entre os serviços).
* **Segurança (Security Groups):** Regras de firewall granulares que seguem o princípio do menor privilégio, permitindo apenas a comunicação estritamente necessária entre os componentes.
* **Balanceamento de Carga (ALB):** Um Application Load Balancer serve como ponto de entrada único para a aplicação, distribuindo o tráfego e utilizando um certificado SSL/TLS para comunicação segura (HTTPS).

## 🛠️ Tecnologias Utilizadas

* **Terraform:** Para a declaração da infraestrutura como código (IaC).
* **Ansible:** Para o gerenciamento de configuração pós-provisionamento (instalação de Docker, etc.).
* **GitHub Actions:** Como plataforma de orquestração e CI/CD para automação do fluxo de trabalho.
* **AWS (Amazon Web Services):** Como provedor de nuvem principal.
* **Git & GitFlow:** Para versionamento de código e estratégia de branches.

## 📁 Estrutura do Repositório

O projeto é organizado de forma modular para máxima reutilização e clareza:

├── .github/workflows/    # Contém os pipelines de CI/CD (GitHub Actions)
├── ansible/              # Contém os playbooks de configuração do Ansible
├── environments/         # Onde a infraestrutura é efetivamente executada
│   ├── aws/
│   │   ├── teste/        # Arquivos de configuração para o ambiente de Teste
│   │   └── homol/        # Arquivos de configuração para o ambiente de Homologação
├── modules/              # Blocos de construção reutilizáveis da infraestrutura
│   ├── aws/
│   │   ├── networking/   # Módulo para criar a VPC, sub-redes, etc.
│   │   ├── security/     # Módulo para criar os Security Groups
│   │   └── ...           # Outros módulos
└── ...

## 🚀 Como Usar o Framework

Todo o ciclo de vida da infraestrutura (criação e destruição) é gerenciado exclusivamente pelo pipeline do GitHub Actions.

1.  Navegue até a aba **"Actions"** no repositório do GitHub.
2.  Na lista de workflows à esquerda, selecione **"Terraform TCC Pipeline"**.
3.  Clique no botão **"Run workflow"**.
4.  Selecione a **branch** que contém o código a ser executado.
5.  No menu **"Ambiente a ser gerenciado"**, escolha o ambiente desejado (ex: `homol`).
6.  No menu **"Ação a ser executada"**, escolha `apply` (para criar/atualizar) ou `destroy` (para destruir).
7.  Clique no botão verde **"Run workflow"** para iniciar a automação.

## 🔑 Acesso Administrativo

As instruções detalhadas para acessar os ambientes via SSH (através do Bastion Host) estão documentadas no arquivo:

➡️ **[Guia de Acesso Administrativo](./ACESSOS.md)**

## 👨‍💻 Autor

* **Alisson Lima**
    * GitHub: `[alisson92](https://github.com/alisson92)`
    * LinkedIn: `https://www.linkedin.com/in/alisson-correa-lima-8404ab233/`
