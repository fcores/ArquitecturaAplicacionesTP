#!/bin/bash
# Script para desplegar TicketPardo en Minikube

set -e

echo "🎯 Desplegando TicketPardo en Minikube..."

# Verificar que Minikube esté instalado
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube no está instalado. Ejecuta primero setup-ec2.sh"
    exit 1
fi

# Verificar que kubectl esté instalado
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl no está instalado. Ejecuta primero setup-ec2.sh"
    exit 1
fi

# Iniciar Minikube si no está corriendo
echo "🚀 Iniciando Minikube..."
if ! minikube status &> /dev/null; then
    minikube start --driver=docker --cpus=2 --memory=4096 --disk-size=20g
    echo "✅ Minikube iniciado"
else
    echo "✅ Minikube ya está corriendo"
fi

# Habilitar addons necesarios
echo "🔌 Habilitando addons de Minikube..."
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable metrics-server

# Configurar Docker para usar el registry de Minikube
echo "🐳 Configurando Docker para Minikube..."
eval $(minikube docker-env)

# Construir imágenes Docker
echo "🏗️ Construyendo imágenes Docker..."

# Construir imagen del backend
echo "   📦 Construyendo backend..."
docker build -t ticketpardo-backend:latest -f backend/Dockerfile ./backend/

# Construir imagen del frontend con proxy reverso
echo "   🌐 Construyendo frontend con proxy reverso..."
docker build -t ticketpardo-frontend:latest -f Dockerfile.frontend --build-arg REACT_APP_API_URL=/api .

# Verificar que las imágenes se construyeron correctamente
echo "🔍 Verificando imágenes construidas..."
docker images | grep ticketpardo

# Aplicar manifiestos de Kubernetes
echo "☸️ Desplegando en Kubernetes..."

# Crear namespace
kubectl apply -f k8s/namespace.yaml

# Aplicar ConfigMap
kubectl apply -f k8s/configmap.yaml

# Desplegar backend
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# Desplegar frontend
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Aplicar Ingress
kubectl apply -f k8s/ingress.yaml

# Esperar a que los pods estén listos
echo "⏳ Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=ticketpardo-backend -n ticketpardo --timeout=300s
kubectl wait --for=condition=ready pod -l app=ticketpardo-frontend -n ticketpardo --timeout=300s

# Obtener información del despliegue
echo "📊 Estado del despliegue:"
kubectl get all -n ticketpardo

# Obtener la URL de acceso
echo ""
echo "🌐 URLs de acceso:"
MINIKUBE_IP=$(minikube ip)
FRONTEND_PORT=$(kubectl get svc ticketpardo-frontend-service -n ticketpardo -o jsonpath='{.spec.ports[0].nodePort}')

if [ "$FRONTEND_PORT" != "null" ] && [ -n "$FRONTEND_PORT" ]; then
    echo "   Frontend: http://$MINIKUBE_IP:$FRONTEND_PORT"
else
    # Si no hay NodePort, usar port-forward
    echo "   Configurando port-forward para acceso..."
    echo "   Ejecuta en otra terminal: kubectl port-forward svc/ticketpardo-frontend-service 3000:80 -n ticketpardo"
    echo "   Luego accede a: http://localhost:3000"
fi

# URL del backend
BACKEND_PORT=$(kubectl get svc ticketpardo-backend-service -n ticketpardo -o jsonpath='{.spec.ports[0].nodePort}')
if [ "$BACKEND_PORT" != "null" ] && [ -n "$BACKEND_PORT" ]; then
    echo "   Backend API: http://$MINIKUBE_IP:$BACKEND_PORT"
    echo "   API Docs: http://$MINIKUBE_IP:$BACKEND_PORT/docs"
else
    echo "   Para acceder al backend, ejecuta: kubectl port-forward svc/ticketpardo-backend-service 8000:8000 -n ticketpardo"
    echo "   Luego accede a: http://localhost:8000/docs"
fi

# Comandos útiles
echo ""
echo "🛠️ Comandos útiles:"
echo "   Ver logs del backend: kubectl logs -f deployment/ticketpardo-backend -n ticketpardo"
echo "   Ver logs del frontend: kubectl logs -f deployment/ticketpardo-frontend -n ticketpardo"
echo "   Dashboard de Minikube: minikube dashboard"
echo "   Escalar backend: kubectl scale deployment ticketpardo-backend --replicas=3 -n ticketpardo"
echo "   Reiniciar despliegue: kubectl rollout restart deployment/ticketpardo-backend -n ticketpardo"

# Verificar que el frontend no tiene referencias a localhost
echo ""
echo "🔍 Verificando configuración del frontend..."
kubectl wait --for=condition=ready pod -l app=ticketpardo-frontend -n ticketpardo --timeout=60s
sleep 5
kubectl exec -n ticketpardo deployment/ticketpardo-frontend -- sh -c 'grep -R "localhost:8000" /usr/share/nginx/html || echo "✅ OK: sin referencias a localhost"'

echo ""
echo "✅ ¡Despliegue completado exitosamente!"
