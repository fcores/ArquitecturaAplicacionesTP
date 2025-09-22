#!/bin/bash
# Script para configurar IP específica de EC2: 18.191.169.71

set -e

EC2_IP="18.191.169.71"

echo "🌐 Configurando aplicación para IP específica: $EC2_IP"

# Crear archivo .env con IP específica
cat > .env <<EOF
# Configuración para IP específica de EC2
EC2_IP=$EC2_IP

# === OPCIÓN 1: PROXY REVERSO (RECOMENDADO) ===
# El frontend accede a /api y nginx hace el proxy
VITE_API_BASE=/api

# === OPCIÓN 2: ACCESO DIRECTO (ALTERNATIVO) ===
# Descomenta la siguiente línea si quieres acceso directo al backend
# VITE_API_BASE=http://$EC2_IP:8000/api

# Configuración del entorno
REACT_APP_ENVIRONMENT=production
ENVIRONMENT=production

# CORS para el backend (incluye la IP específica)
CORS_ORIGINS=http://$EC2_IP:3000,http://$EC2_IP,http://localhost:3000,http://127.0.0.1:3000

# Docker/Kubernetes
DOCKER_REGISTRY=localhost:5000
IMAGE_TAG=latest
EOF

echo "✅ Archivo .env creado con configuración para $EC2_IP"

# Exportar variables para el shell actual
export EC2_IP
export VITE_API_BASE="/api"
export CORS_ORIGINS="http://$EC2_IP:3000,http://$EC2_IP,http://localhost:3000,http://127.0.0.1:3000"

echo ""
echo "🎯 Configuración aplicada:"
echo "   IP EC2: $EC2_IP"
echo "   Frontend API Base: /api (proxy reverso)"
echo "   URLs de acceso:"
echo "     - Frontend: http://$EC2_IP:3000"
echo "     - Backend (directo): http://$EC2_IP:8000"
echo "     - API via proxy: http://$EC2_IP:3000/api/"
echo ""
echo "📋 Opciones de configuración:"
echo ""
echo "1. 🔄 PROXY REVERSO (Recomendado - ya configurado):"
echo "   - Frontend usa: /api"
echo "   - Nginx hace proxy al backend"
echo "   - Sin problemas de CORS"
echo ""
echo "2. 🌐 ACCESO DIRECTO (Alternativo):"
echo "   - Edita .env y cambia:"
echo "     VITE_API_BASE=http://$EC2_IP:8000/api"
echo "   - Reconstruye la imagen después del cambio"
echo ""
echo "🚀 Para aplicar cambios:"
echo "   bash scripts/build-images.sh"
echo "   bash scripts/deploy-minikube.sh"
