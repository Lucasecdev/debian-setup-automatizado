#!/bin/bash

# Variáveis editáveis
NOME_USUARIO="Lucas"       # <- Altere aqui com seu nome
INTERFACE_REDE="eth1"
SSH_PORTA=7500

# 0. Garante que o sudo esteja instalado
if ! command -v sudo >/dev/null 2>&1; then
    echo "[0/7] sudo não encontrado. Instalando..."
    apt update && apt install -y sudo
fi

# 1. Remove repositório do CD-ROM
echo "[1/7] Corrigindo sources.list..."
sudo sed -i '/cdrom:/s/^/#/' /etc/apt/sources.list

# 2. Adiciona repositórios oficiais
cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware

deb http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
EOF

# 3. Atualiza pacotes
echo "[2/7] Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 4. Configura a interface de rede para iniciar com DHCP
echo "[3/7] Configurando interface de rede: $INTERFACE_REDE..."
if ! grep -q "$INTERFACE_REDE" /etc/network_

