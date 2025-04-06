#!/bin/bash

# Variáveis editáveis
NOME_USUARIO="Lucas"       # <- Altere aqui com seu nome
INTERFACE_REDE="eth1"
SSH_PORTA=7500

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
if ! grep -q "$INTERFACE_REDE" /etc/network/interfaces; then
    echo -e "\nauto $INTERFACE_REDE\niface $INTERFACE_REDE inet dhcp" | sudo tee -a /etc/network/interfaces
fi

# 5. Instala pacotes
echo "[4/7] Instalando pacotes necessários..."
sudo apt install -y sudo vim net-tools aptitude htop cmatrix figlet openssh-server

# 6. Configura SSH na porta desejada
echo "[5/7] Configurando SSH para porta $SSH_PORTA..."
sudo sed -i "s/^#Port 22/Port $SSH_PORTA/" /etc/ssh/sshd_config
sudo systemctl restart ssh

# 7. Cria os banners com figlet
echo "[6/7] Criando banners com figlet..."
figlet "$NOME_USUARIO" | sudo tee /etc/issue.net > /dev/null
figlet "FATEC" | sudo tee /etc/motd > /dev/null
if ! grep -q "figlet \"DEBIAN 12\"" ~/.bashrc; then
    echo 'figlet "DEBIAN 12"' >> ~/.bashrc
fi

echo "[7/7] Configuração concluída!"
