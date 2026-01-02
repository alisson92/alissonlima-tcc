# Guia de Acesso Administrativo (Multicloud)

Este documento detalha os procedimentos para acessar a infraestrutura dos ambientes via SSH para os times de Infraestrutura e DevOps.

O acesso aos servidores internos (Aplicação e Banco de Dados) é sempre realizado através de um "salto" pelo **Bastion Host** do respectivo provedor de nuvem, utilizando SSH Agent Forwarding (`-A`).

---

## Ambiente de Teste - (TESTE)

### 1. Conexão ao Bastion Host

Devido à arquitetura multicloud, cada provedor possui um ponto de entrada específico para evitar conflitos de identidade SSH.

### Acesso via AWS:

```bash
ssh -A ubuntu@bastion-aws-teste.alissonlima.dev.br
```

### Acesso via Azure:

```bash
ssh -A ubuntu@bastion-azure-teste.alissonlima.dev.br
```

### Nota de Padronização:

Em ambos os casos, o terminal exibirá o prompt padronizado: `ubuntu@bastion:~$`.

### 2. Conexão aos Servidores Internos (Comandos Idênticos para AWS/Azure)

Uma vez dentro de qualquer Bastion, os comandos para acessar as instâncias internas são exatamente os mesmos, graças à paridade de DNS privado e hostnames.

### Acessar o Servidor de Aplicação

```bash
ssh ubuntu@app-server.internal.alissonlima.dev.br
```

### Acessar o Servidor de Banco de Dados

```bash
ssh ubuntu@db-server.internal.alissonlima.dev.br
```

### Ambiente de Homologação - (HOMOL)

### 1. Conexão ao Bastion Host

Seguindo o padrão de segmentação por nuvem.

### AWS:

```bash
ssh -A ubuntu@bastion-aws-homol.alissonlima.dev.br
```

### Azure:

```bash
ssh -A ubuntu@bastion-azure-homol.alissonlima.dev.br
```

### 2. Conexão aos Servidores Internos

### Acessar o Servidor de Aplicação

```bash
ssh ubuntu@app-server.internal.alissonlima.dev.br
```

### Acessar o Servidor de Banco de Dados

```bash
ssh ubuntu@db-server.internal.alissonlima.dev.br
```

### Ambiente de Produção - (PROD)

### 1. Conexão ao Bastion Host

Ponto de entrada único por provedor para o ambiente produtivo.

### AWS:

```bash
ssh -A ubuntu@bastion-aws-prod.alissonlima.dev.br
```

### Azure:

```bash
ssh -A ubuntu@bastion-azure-prod.alissonlima.dev.br
```

### 2. Conexão aos Servidores Internos

Em produção, o framework suporta múltiplos nós de aplicação para alta disponibilidade.

### Servidores de Aplicação:

```bash
ssh ubuntu@app-server-0.internal.alissonlima.dev.br
ssh ubuntu@app-server-1.internal.alissonlima.dev.br
```

### Servidor de Banco de Dados:

```bash
ssh ubuntu@db-server.internal.alissonlima.dev.br
```
