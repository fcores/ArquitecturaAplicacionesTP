#!/bin/bash
# Script para configurar EC2 con Docker, Minikube y la aplicación TicketPardo

set -e

echo "🚀 Iniciando configuración de EC2 para TicketPardo..."

# Actualizar el sistema
echo "📦 Actualizando paquetes del sistema..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar dependencias básicas
echo "🔧 Instalando dependencias básicas..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    build-essential

# Instalar Docker
echo "🐳 Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Agregar usuario al grupo docker
    sudo usermod -aG docker $USER
    
    # Habilitar Docker al inicio
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "✅ Docker ya está instalado"
fi

# Instalar Docker Compose standalone
echo "🔨 Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "✅ Docker Compose ya está instalado"
fi

# Instalar kubectl
echo "⚙️ Instalando kubectl..."
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
else
    echo "✅ kubectl ya está instalado"
fi

# Instalar Minikube
echo "🎯 Instalando Minikube..."
if ! command -v minikube &> /dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo "✅ Minikube ya está instalado"
fi

# Instalar Python y pip
echo "🐍 Instalando Python y dependencias..."
sudo apt-get install -y python3 python3-pip python3-venv

# Instalar Node.js y npm
echo "📦 Instalando Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "✅ Node.js ya está instalado"
fi

# Configurar firewall
echo "🔒 Configurando firewall..."
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 3000/tcp    # Frontend React
sudo ufw allow 8000/tcp    # Backend FastAPI
sudo ufw allow 30000:32767/tcp  # NodePort range para Kubernetes
sudo ufw --force enable

# Crear directorio para la aplicación
echo "📁 Creando directorio para la aplicación..."
mkdir -p /home/$USER/ticketpardo
cd /home/$USER/ticketpardo

echo "✅ Configuración básica completada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Clona el repositorio: git clone <tu-repo-url> ."
echo "2. Ejecuta: bash scripts/deploy-minikube.sh"
echo ""
echo "🔄 Es necesario reiniciar la sesión para que los cambios de grupo de Docker tomen efecto:"
echo "   newgrp docker"
echo "   o"
echo "   exit y volver a conectarse por SSH"
