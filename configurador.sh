#!/bin/bash

echo "[1/8] Corrigindo repositórios do Debian 12..."
cat <<EOF > /etc/apt/sources.list
deb http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm main contrib non-free-firmware

deb http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free-firmware

deb http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb-src http://ftp.br.debian.org/debian/ bookworm-updates main contrib non-free-firmware
EOF

echo "[2/8] Atualizando pacotes..."
apt update && apt upgrade -y

echo "[3/8] Configurando rede para interface eth1 (caso exista)..."
if grep -q "allow-hotplug eth1" /etc/network/interfaces; then
    echo "eth1 já está configurada."
else
    echo -e "\nallow-hotplug eth1\niface eth1 inet dhcp" >> /etc/network/interfaces
    systemctl restart networking
fi

echo "[4/8] Instalando pacotes essenciais..."
apt install -y sudo vim net-tools aptitude htop cmatrix figlet openssh-server libpam-google-authenticator

echo "[5/8] Criando usuário 'lucas' com permissões sudo (se não existir)..."
if id "lucas" &>/dev/null; then
    echo "Usuário 'lucas' já existe."
else
    useradd -m -s /bin/bash lucas
    echo "lucas:senha123" | chpasswd
    usermod -aG sudo lucas
fi

echo "[6/8] Configurando SSH na porta 7500..."
sed -i 's/^#Port 22/Port 7500/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

echo "[7/8] Configurando banners com figlet..."
figlet "Lucas" > /etc/issue.net
figlet "FATEC" > /etc/issue
echo "figlet 'DEBIAN 12'" >> /etc/profile

sed -i 's|^#Banner none|Banner /etc/issue.net|' /etc/ssh/sshd_config

echo "[8/8] Configurando Google Authenticator para root e lucas..."

# Habilita o uso do Google Authenticator via PAM
sed -i '/@include common-auth/a auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd

# Ativa ChallengeResponseAuthentication
sed -i 's/^#ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Instruções pós-script
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

# Reinicia SSH
systemctl restart ssh
