# Arquitetura — Diagramas Complementares

Este documento reúne diagramas de arquitetura que não são específicos de um
único guia (`ACESSOS.md`, `CI-QUALIDADE.md`) nem cabem no resumo do
`README.md`. Complementam a descrição textual já existente no `CLAUDE.md`.

## Split de DNS (público x privado)

O DNS público (Cloudflare) e o DNS privado (Route 53 / Azure Private DNS)
resolvem propósitos diferentes: o primeiro expõe a aplicação e o Bastion à
internet, terminando TLS na borda; o segundo resolve hostnames internos
(`app-server`, `db-server`) para tráfego que nunca sai da rede virtual.

```mermaid
flowchart LR
    Client(["Cliente externo"])
    Op(["Operador"])
    subgraph PublicDNS["DNS Público (Cloudflare)"]
        CF["Cloudflare<br/>proxy + terminação TLS"]
    end
    LB["Load Balancer"]
    Bastion["Bastion Host"]
    subgraph PrivateDNS["DNS Privado (Route 53 / Azure Private DNS)"]
        Zone["Zona privada<br/>app-server, db-server"]
    end
    AppServer["App Server"]
    DBServer[("DB Server")]

    Client -->|HTTPS| CF
    CF -->|HTTP| LB
    Op -->|"SSH (A record sem proxy)"| CF
    CF --> Bastion
    Bastion -.resolve.-> Zone
    AppServer -.resolve.-> Zone
    DBServer -.resolve.-> Zone
```

## Fluxo do pipeline de CI/CD (JIT SSH)

Para cada execução (`apply`/`destroy`), o pipeline abre uma regra de SSH
temporária no Security Group/NSG do Bastion, restrita ao IP do runner do
GitHub Actions, e sempre a fecha ao final — mesmo que um passo anterior falhe
(`if: always()`).

```mermaid
sequenceDiagram
    participant GH as GitHub Actions Runner
    participant SG as Bastion SG/NSG
    participant BH as Bastion Host
    participant APP as App/DB Servers

    GH->>SG: Abre regra JIT (IP do runner, porta 22)
    GH->>BH: SSH (ProxyCommand)
    GH->>APP: Gera inventory Ansible via bastion
    GH->>APP: Executa playbook_docker.yml
    GH->>APP: Executa playbook_nginx_container.yml
    GH->>SG: Fecha regra JIT (if: always())
```

## Ver também

- [`CLAUDE.md`](../CLAUDE.md) — descrição textual completa da arquitetura, camadas de módulo e convenções.
- [`docs/ACESSOS.md`](./ACESSOS.md) — guia de acesso administrativo via SSH (inclui o diagrama do modelo de acesso).
- [`docs/CI-QUALIDADE.md`](./CI-QUALIDADE.md) — gates de qualidade do pipeline de PR.
