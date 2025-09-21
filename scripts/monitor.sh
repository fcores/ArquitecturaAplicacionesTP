#!/bin/bash
# Script de monitoreo para TicketPardo

echo "📊 Monitor de TicketPardo"
echo "========================"

# Verificar estado de Minikube
echo "🎯 Estado de Minikube:"
if command -v minikube &> /dev/null; then
    minikube status
else
    echo "❌ Minikube no instalado"
fi

echo ""
echo "☸️ Estado de Kubernetes:"
if kubectl get namespace ticketpardo &> /dev/null; then
    echo "✅ Namespace ticketpardo existe"
    
    echo ""
    echo "📦 Pods:"
    kubectl get pods -n ticketpardo
    
    echo ""
    echo "🔗 Servicios:"
    kubectl get services -n ticketpardo
    
    echo ""
    echo "🌐 Ingress:"
    kubectl get ingress -n ticketpardo
    
    echo ""
    echo "📊 Uso de recursos:"
    kubectl top pods -n ticketpardo 2>/dev/null || echo "Metrics server no disponible"
    
    echo ""
    echo "🔍 Últimos eventos:"
    kubectl get events -n ticketpardo --sort-by='.lastTimestamp' | tail -10
    
else
    echo "❌ Namespace ticketpardo no existe"
fi

echo ""
echo "🐳 Contenedores Docker:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "💾 Uso de disco:"
df -h

echo ""
echo "🧠 Uso de memoria:"
free -h

echo ""
echo "⚡ Carga del sistema:"
uptime

echo ""
echo "🔗 URLs de acceso:"
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    MINIKUBE_IP=$(minikube ip)
    echo "   Minikube IP: $MINIKUBE_IP"
    echo "   Dashboard: minikube dashboard --url"
    echo "   Port-forward frontend: kubectl port-forward svc/ticketpardo-frontend-service 3000:80 -n ticketpardo"
    echo "   Port-forward backend: kubectl port-forward svc/ticketpardo-backend-service 8000:8000 -n ticketpardo"
fi
