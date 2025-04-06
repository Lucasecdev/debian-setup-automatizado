#!/bin/bash

# CONFIGURAÇÃO AUTOMÁTICA DO GOOGLE AUTHENTICATOR
# Autor: Lucas Vinícius
# Descrição: Instala e configura autenticação em duas etapas com Google Authenticator no Debian

echo "[1/9] Atualizando e instalando aptitude..."
apt update
apt install -y aptitude

echo "[2/9] Configurando fuso horário..."
dpkg-reconfigure tzdata

echo "[3/9] Instalando e sincronizando com NTP..."
aptitude install -y ntpdate
aptitude install -y ntp

echo "[4/9] Verificando data e hora atual..."
date

echo "[5/9] Instalando libpam-google-authenticator..."
apt install -y libpam-google-authenticator

echo "[6/9] Executando google-authenticator para o usuário atual ($(whoami))..."
google-authenticator

echo "[7/9] Alterando sshd_config para permitir autenticação por teclado (2FA)..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -q "^#*KbdInteractiveAuthentication" "$SSHD_CONFIG"; then
    sed -i 's/^#*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' "$SSHD_CONFIG"
else
    echo "KbdInteractiveAuthentication yes" >> "$SSHD_CONFIG"
fi

echo "[8/9] Adicionando autenticação ao PAM do SSH..."
PAM_SSHD="/etc/pam.d/sshd"
if ! grep -q "pam_google_authenticator.so" "$PAM_SSHD"; then
    sed -i '1iauth required pam_google_authenticator.so nullok' "$PAM_SSHD"
fi

echo "[8.1/9] Adicionando autenticação ao PAM global (common-auth)..."
PAM_COMMON="/etc/pam.d/common-auth"
if ! grep -q "pam_google_authenticator.so" "$PAM_COMMON"; then
    sed -i '1iauth required pam_google_authenticator.so nullok' "$PAM_COMMON"
fi

echo "[9/9] Reiniciando serviço SSH..."
systemctl restart ssh

echo "✅ Google Authenticator instalado e configurado com sucesso!"
