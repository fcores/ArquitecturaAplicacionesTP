#!/bin/bash

# Script de deployment para AWS EC2 con Minikube
# Uso: ./deploy-aws.sh [PUBLIC_IP]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 TicketPardo - Deployment en AWS EC2${NC}"
echo "=================================================="

# Verificar si se proporcionó IP pública
PUBLIC_IP=${1:-""}
if [ -z "$PUBLIC_IP" ]; then
    echo -e "${YELLOW}⚠️  No se proporcionó IP pública. Usando configuración por defecto.${NC}"
else
    echo -e "${GREEN}🌐 IP Pública: $PUBLIC_IP${NC}"
fi

# Verificar que minikube esté funcionando
echo -e "${BLUE}🔍 Verificando Minikube...${NC}"
if ! minikube status > /dev/null 2>&1; then
    echo -e "${RED}❌ Minikube no está funcionando. Iniciando...${NC}"
    minikube start --driver=docker
else
    echo -e "${GREEN}✅ Minikube está funcionando${NC}"
fi

# Configurar Docker para usar el registro de Minikube
echo -e "${BLUE}🐳 Configurando Docker para Minikube...${NC}"
eval $(minikube docker-env)

# Build de las imágenes
echo -e "${BLUE}🏗️  Construyendo imágenes Docker...${NC}"

# Backend
echo -e "${YELLOW}📦 Construyendo imagen del backend...${NC}"
docker build -t ticketpardo-backend:latest -f backend/Dockerfile ./backend

# Frontend
echo -e "${YELLOW}📦 Construyendo imagen del frontend...${NC}"
if [ ! -z "$PUBLIC_IP" ]; then
    docker build -t ticketpardo-frontend:latest \
        --build-arg REACT_APP_API_URL="http://$PUBLIC_IP:30080/api" \
        -f Dockerfile.frontend .
else
    docker build -t ticketpardo-frontend:latest -f Dockerfile.frontend .
fi

echo -e "${GREEN}✅ Imágenes construidas exitosamente${NC}"

# Aplicar configuraciones de Kubernetes
echo -e "${BLUE}☸️  Aplicando configuraciones de Kubernetes...${NC}"

# Crear namespace si no existe
kubectl create namespace ticketpardo --dry-run=client -o yaml | kubectl apply -f -

# Aplicar ConfigMap con IP pública si se proporcionó
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "${YELLOW}📝 Creando ConfigMap con IP pública...${NC}"
    kubectl create configmap app-config \
        --from-literal=PUBLIC_IP="$PUBLIC_IP" \
        --from-literal=ENVIRONMENT="production" \
        --from-literal=CORS_ORIGINS="*" \
        --namespace=ticketpardo \
        --dry-run=client -o yaml | kubectl apply -f -
else
    kubectl apply -f k8s/configmap.yaml
fi

# Aplicar el resto de configuraciones
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

echo -e "${GREEN}✅ Configuraciones aplicadas${NC}"

# Esperar a que los pods estén listos
echo -e "${BLUE}⏳ Esperando a que los pods estén listos...${NC}"
kubectl wait --for=condition=ready pod -l app=backend --namespace=ticketpardo --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend --namespace=ticketpardo --timeout=300s

# Obtener información de los servicios
echo -e "${BLUE}📋 Información de los servicios:${NC}"
echo "=================================================="

# NodePorts
BACKEND_NODEPORT=$(kubectl get svc backend-service -n ticketpardo -o jsonpath='{.spec.ports[0].nodePort}')
FRONTEND_NODEPORT=$(kubectl get svc frontend-service -n ticketpardo -o jsonpath='{.spec.ports[0].nodePort}')

echo -e "${GREEN}🎯 URLs de acceso:${NC}"
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "   Frontend: ${YELLOW}http://$PUBLIC_IP:$FRONTEND_NODEPORT${NC}"
    echo -e "   Backend:  ${YELLOW}http://$PUBLIC_IP:$BACKEND_NODEPORT${NC}"
    echo -e "   API Docs: ${YELLOW}http://$PUBLIC_IP:$BACKEND_NODEPORT/api/docs${NC}"
else
    MINIKUBE_IP=$(minikube ip)
    echo -e "   Frontend: ${YELLOW}http://$MINIKUBE_IP:$FRONTEND_NODEPORT${NC}"
    echo -e "   Backend:  ${YELLOW}http://$MINIKUBE_IP:$BACKEND_NODEPORT${NC}"
    echo -e "   API Docs: ${YELLOW}http://$MINIKUBE_IP:$BACKEND_NODEPORT/api/docs${NC}"
fi

echo ""
echo -e "${GREEN}🎉 ¡Deployment completado exitosamente!${NC}"
echo "=================================================="

# Mostrar estado de los pods
echo -e "${BLUE}📊 Estado de los pods:${NC}"
kubectl get pods -n ticketpardo

echo ""
echo -e "${BLUE}💡 Comandos útiles:${NC}"
echo "   Ver logs backend:  kubectl logs -f deployment/backend -n ticketpardo"
echo "   Ver logs frontend: kubectl logs -f deployment/frontend -n ticketpardo"
echo "   Ver servicios:     kubectl get svc -n ticketpardo"
echo "   Escalar backend:   kubectl scale deployment backend --replicas=3 -n ticketpardo"
