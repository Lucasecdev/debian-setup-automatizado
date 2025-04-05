# 🚀 Script de Configuração Automatizada - Debian 12

Este repositório contém um script para automatizar a configuração de uma VM Debian "zerada", ideal para testes, ambientes didáticos ou labs de segurança.

---

## ✅ Funcionalidades

- Atualização de repositórios do Debian 12
- Instalação de pacotes essenciais (`sudo`, `vim`, `net-tools`, etc)
- Configuração de interface de rede secundária (`eth1`)
- Instalação e configuração do SSH na porta **7500**
- Criação do usuário `lucas` com sudo
- Personalização de banners com `figlet`
- Ativação do Google Authenticator (2FA) para `root` e `lucas`

---

## 🖥️ Execução direta

> Execute na sua VM Debian já com rede configurada:

```bash
bash <(curl -s https://raw.githubusercontent.com/Lucasecdev/debian-setup-automatizado/main/configurador.sh)
