#!/bin/bash
# Script de despliegue rápido para TicketPardo en EC2 con Minikube

set -e

echo "🚀 Despliegue rápido de TicketPardo en EC2"
echo "=========================================="

# Verificar si es la primera ejecución
if [ ! -f "/tmp/ticketpardo-setup-done" ]; then
    echo "🔧 Primera ejecución detectada. Configurando sistema..."
    bash scripts/setup-ec2.sh
    
    echo "✅ Configuración inicial completada"
    echo "🔄 Es necesario reiniciar la sesión para aplicar los cambios de grupo de Docker"
    echo "   Ejecuta: newgrp docker"
    echo "   O reconéctate por SSH y vuelve a ejecutar este script"
    
    touch /tmp/ticketpardo-setup-done
    exit 0
fi

# Verificar que Docker funcione sin sudo
if ! docker ps &> /dev/null; then
    echo "❌ Error: Docker requiere permisos. Ejecuta: newgrp docker"
    exit 1
fi

echo "🏗️ Construyendo imágenes..."
bash scripts/build-images.sh

echo "🎯 Desplegando en Minikube..."
bash scripts/deploy-minikube.sh

echo ""
echo "🎉 ¡Despliegue completado!"
echo "La aplicación debería estar disponible en unos minutos."
