#!/bin/bash

# Garantir que sudo e curl estejam disponíveis
echo "[0/8] Verificando pré-requisitos..."

if ! command -v sudo &>/dev/null; then
    echo "→ Instalando 'sudo'..."
    apt update && apt install -y sudo
fi

if ! command -v curl &>/dev/null; then
    echo "→ Instalando 'curl'..."
    sudo apt install -y curl
fi

echo "[1/8] Corrigindo repositórios do Debian 12..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware

deb http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
EOF

echo "[2/8] Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "[3/8] Configurando rede para interface eth1 (caso exista)..."
if grep -q "allow-hotplug eth1" /etc/network/interfaces; then
    echo "→ eth1 já está configurada."
else
    echo -e "\nallow-hotplug eth1\niface eth1 inet dhcp" | sudo tee -a /etc/network/interfaces
    sudo systemctl restart networking
fi

echo "[4/8] Instalando pacotes essenciais..."
sudo apt install -y vim net-tools aptitude htop cmatrix figlet openssh-server libpam-google-authenticator

echo "[5/8] Criando usuário 'lucas' com sudo (se necessário)..."
if id "lucas" &>/dev/null; then
    echo "→ Usuário 'lucas' já existe."
else
    sudo useradd -m -s /bin/bash lucas
    echo "lucas:senha123" | sudo chpasswd
    sudo usermod -aG sudo lucas
fi

echo "[6/8] Configurando SSH na porta 7500..."
sudo sed -i 's/^#Port 22/Port 7500/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[7/8] Configurando banners com figlet..."
figlet "Lucas" | sudo tee /etc/issue.net > /dev/null
figlet "FATEC" | sudo tee /etc/issue > /dev/null
echo "figlet 'DEBIAN 12'" | sudo tee -a /etc/profile > /dev/null

sudo sed -i 's|^#Banner none|Banner /etc/issue.net|' /etc/ssh/sshd_config

echo "[8/8] Configurando Google Authenticator para root e lucas..."

# Adiciona regra no PAM do SSH, se ainda não existir
if ! grep -q "auth required pam_google_authenticator.so" /etc/pam.d/sshd; then
    sudo sed -i '/@include common-auth/a auth required pam_google_authenticator.so' /etc/pam.d/sshd
fi

# Ajusta o sshd_config para 2FA com senha + OTP
sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
if ! grep -q "^AuthenticationMethods" /etc/ssh/sshd_config; then
    echo "AuthenticationMethods password,keyboard-interactive" | sudo tee -a /etc/ssh/sshd_config
else
    sudo sed -i 's/^AuthenticationMethods.*/AuthenticationMethods password,keyboard-interactive/' /etc/ssh/sshd_config
fi

# Instruções finais
cat <<FIM

======================================================
✅ Script finalizado!
➡ Execute os seguintes comandos MANUALMENTE:
------------------------------------------------------
1. Para root:
   google-authenticator

2. Para o usuário lucas:
   su - lucas
   google-authenticator
------------------------------------------------------
⚠️ O SSH está na porta 7500.
⚠️ Autenticação com senha está desativada.
⚠️ Use Google Authenticator para logar.
======================================================

FIM

sudo systemctl restart ssh

