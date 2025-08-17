### Guia de Acesso Administrativo

Este documento detalha os procedimentos para acessar a infraestrutura dos ambientes via SSH para os times de Infraestrutura e DevOps.

O acesso aos servidores internos (Aplicação e Banco de Dados) é sempre realizado através de um "salto" pelo **Bastion Host** do respectivo ambiente, utilizando SSH Agent Forwarding (`-A`).

---

### Ambiente de Teste - (TESTE)

### 1. Conexão ao Bastion Host

O acesso aos servidores internos é feito através do Bastion Host, utilizando SSH Agent Forwarding (`-A`).

```bash
ssh -A ubuntu@bastion-teste.alissonlima.dev.br
```

### 2. Conexão aos Servidores Internos (a partir do Bastion)

Uma vez dentro do Bastion, use os endereços de DNS privados para acessar os servidores.

### Acessar o Servidor de Aplicação

```bash
ssh ubuntu@app-server.teste.internal.alissonlima.dev.br
```

### Acessar o Servidor de Banco de Dados

```bash
ssh ubuntu@db-server.teste.internal.alissonlima.dev.br
```

### Ambiente de Homologação - (HOMOL)

### 1. Conexão ao Bastion Host

O processo é o mesmo, mas utilizando o DNS específico de homologação.

```bash
ssh -A ubuntu@bastion-homol.alissonlima.dev.br
```

### 2. Conexão aos Servidores Internos (a partir do Bastion)

Uma vez dentro do Bastion de homologação, use os respectivos endereços de DNS privados.

### Acessar o Servidor de Aplicação

```bash
ssh ubuntu@app-server.homol.internal.alissonlima.dev.br
```

### Acessar o Servidor de Banco de Dados

```bash
ssh ubuntu@db-server.homol.internal.alissonlima.dev.br
```

### Ambiente de Produção - (PROD)

### 1. Conexão ao Bastion Host

```bash
ssh -A ubuntu@bastion-prod.alissonlima.dev.br
```

### 2. Conexão aos Servidores Internos (a partir do Bastion)

### Acessar o Servidor de Aplicação

```bash
ssh ubuntu@app-server.prod.internal.alissonlima.dev.br
```

### Acessar o Servidor de Banco de Dados

```bash
ssh ubuntu@db-server.prod.internal.alissonlima.dev.br
```