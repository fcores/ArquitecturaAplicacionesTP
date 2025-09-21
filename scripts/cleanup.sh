#!/bin/bash
# Script para limpiar recursos de TicketPardo

set -e

echo "🧹 Limpiando recursos de TicketPardo..."

# Función para preguntar confirmación
confirm() {
    read -p "$1 (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Limpiar recursos de Kubernetes
if kubectl get namespace ticketpardo &> /dev/null; then
    if confirm "¿Eliminar recursos de Kubernetes?"; then
        echo "☸️ Eliminando recursos de Kubernetes..."
        kubectl delete namespace ticketpardo --ignore-not-found=true
        echo "✅ Recursos de Kubernetes eliminados"
    fi
fi

# Limpiar contenedores de Docker Compose
if [ -f "docker-compose.yml" ]; then
    if confirm "¿Eliminar contenedores de Docker Compose?"; then
        echo "🐳 Eliminando contenedores de Docker Compose..."
        docker-compose down --volumes --remove-orphans
        echo "✅ Contenedores de Docker Compose eliminados"
    fi
fi

# Limpiar imágenes Docker
if confirm "¿Eliminar imágenes Docker de TicketPardo?"; then
    echo "🗑️ Eliminando imágenes Docker..."
    docker rmi $(docker images | grep ticketpardo | awk '{print $3}') 2>/dev/null || echo "No hay imágenes de TicketPardo para eliminar"
    echo "✅ Imágenes Docker eliminadas"
fi

# Limpiar volúmenes Docker huérfanos
if confirm "¿Eliminar volúmenes Docker huérfanos?"; then
    echo "📦 Eliminando volúmenes huérfanos..."
    docker volume prune -f
    echo "✅ Volúmenes eliminados"
fi

# Parar Minikube
if command -v minikube &> /dev/null; then
    if minikube status &> /dev/null; then
        if confirm "¿Parar Minikube?"; then
            echo "🎯 Parando Minikube..."
            minikube stop
            echo "✅ Minikube parado"
        fi
    fi
    
    if confirm "¿Eliminar cluster de Minikube completamente?"; then
        echo "💥 Eliminando cluster de Minikube..."
        minikube delete
        echo "✅ Cluster de Minikube eliminado"
    fi
fi

echo ""
echo "✅ ¡Limpieza completada!"
