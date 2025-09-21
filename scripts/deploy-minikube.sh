#!/bin/bash

# Script para desplegar TicketPardo en Minikube
# Uso: ./scripts/deploy-minikube.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Desplegando TicketPardo en Minikube${NC}"
echo -e "${BLUE}====================================${NC}"

# Función para verificar herramientas
check_tools() {
    echo -e "${YELLOW}🔍 Verificando herramientas...${NC}"
    
    if ! command -v minikube &> /dev/null; then
        echo -e "${RED}❌ Minikube no está instalado${NC}"
        echo -e "${YELLOW}Instala Minikube: https://minikube.sigs.k8s.io/docs/start/${NC}"
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl no está instalado${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Herramientas verificadas${NC}"
}

# Función para verificar estado de Minikube
check_minikube_status() {
    echo -e "${YELLOW}🔍 Verificando estado de Minikube...${NC}"
    
    if ! minikube status &> /dev/null; then
        echo -e "${YELLOW}⚠️ Minikube no está corriendo. Iniciando...${NC}"
        minikube start --driver=docker --memory=4096 --cpus=2
        
        echo -e "${BLUE}🔧 Habilitando addons...${NC}"
        minikube addons enable ingress
        minikube addons enable metrics-server
    else
        echo -e "${GREEN}✅ Minikube está corriendo${NC}"
    fi
}

# Función para configurar Docker environment
setup_docker_env() {
    echo -e "${YELLOW}🐳 Configurando Docker environment...${NC}"
    
    # Configurar Docker para usar el daemon de Minikube
    eval $(minikube docker-env)
    
    echo -e "${GREEN}✅ Docker environment configurado${NC}"
}

# Función para construir imágenes
build_images() {
    echo -e "${YELLOW}📦 Construyendo imágenes Docker...${NC}"
    
    # Construir imagen del backend
    echo -e "${BLUE}🔨 Construyendo backend...${NC}"
    docker build -t ticketpardo-backend:local ./backend
    
    # Construir imagen del frontend
    echo -e "${BLUE}🔨 Construyendo frontend...${NC}"
    docker build -f Dockerfile.frontend -t ticketpardo-frontend:local .
    
    echo -e "${GREEN}✅ Imágenes construidas${NC}"
}

# Función para crear configuraciones específicas de Minikube
create_minikube_configs() {
    echo -e "${YELLOW}📝 Creando configuraciones para Minikube...${NC}"
    
    mkdir -p k8s/minikube
    
    # Backend deployment para Minikube
    cat > k8s/minikube/backend-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ticketpardo-backend
  namespace: ticketpardo
  labels:
    app: ticketpardo-backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ticketpardo-backend
  template:
    metadata:
      labels:
        app: ticketpardo-backend
    spec:
      containers:
      - name: backend
        image: ticketpardo-backend:local
        imagePullPolicy: Never
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: DATABASE_URL
          value: "sqlite:///./tickets.db"
        - name: SECRET_KEY
          value: "dev-secret-key-change-in-production"
        - name: DEBUG
          value: "false"
        - name: CORS_ORIGINS
          value: "http://localhost:3000,http://127.0.0.1:3000"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: ticketpardo-backend-service
  namespace: ticketpardo
  labels:
    app: ticketpardo-backend
spec:
  selector:
    app: ticketpardo-backend
  ports:
  - port: 80
    targetPort: 8000
    protocol: TCP
    name: http
  type: ClusterIP
EOF

    # Frontend deployment para Minikube
    cat > k8s/minikube/frontend-deployment.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ticketpardo-frontend
  namespace: ticketpardo
  labels:
    app: ticketpardo-frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ticketpardo-frontend
  template:
    metadata:
      labels:
        app: ticketpardo-frontend
    spec:
      containers:
      - name: frontend
        image: ticketpardo-frontend:local
        imagePullPolicy: Never
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: ticketpardo-frontend-service
  namespace: ticketpardo
  labels:
    app: ticketpardo-frontend
spec:
  selector:
    app: ticketpardo-frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  type: NodePort
EOF

    # Ingress para Minikube
    cat > k8s/minikube/ingress.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ticketpardo-ingress
  namespace: ticketpardo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: ticketpardo.local
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: ticketpardo-backend-service
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ticketpardo-frontend-service
            port:
              number: 80
EOF
    
    echo -e "${GREEN}✅ Configuraciones de Minikube creadas${NC}"
}

# Función para desplegar en Kubernetes
deploy_to_k8s() {
    echo -e "${YELLOW}🚀 Desplegando en Kubernetes...${NC}"
    
    # Aplicar configuraciones
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/minikube/backend-deployment.yaml
    kubectl apply -f k8s/minikube/frontend-deployment.yaml
    kubectl apply -f k8s/minikube/ingress.yaml
    
    echo -e "${GREEN}✅ Configuraciones aplicadas${NC}"
}

# Función para verificar despliegue
verify_deployment() {
    echo -e "${YELLOW}🔍 Verificando despliegue...${NC}"
    
    # Esperar a que los pods estén listos
    echo -e "${BLUE}⏳ Esperando a que los pods estén listos...${NC}"
    kubectl wait --for=condition=ready pod -l app=ticketpardo-backend -n ticketpardo --timeout=300s
    kubectl wait --for=condition=ready pod -l app=ticketpardo-frontend -n ticketpardo --timeout=300s
    
    # Mostrar estado
    echo -e "${BLUE}📊 Estado de los pods:${NC}"
    kubectl get pods -n ticketpardo
    
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    kubectl get services -n ticketpardo
    
    echo -e "${BLUE}📊 Estado del ingress:${NC}"
    kubectl get ingress -n ticketpardo
    
    echo -e "${GREEN}✅ Despliegue verificado${NC}"
}

# Función para mostrar información de acceso
show_access_info() {
    echo -e "${BLUE}🎉 ¡Despliegue completado exitosamente!${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    
    # Obtener IP de Minikube
    MINIKUBE_IP=$(minikube ip)
    
    # Obtener puerto del frontend
    FRONTEND_PORT=$(kubectl get service ticketpardo-frontend-service -n ticketpardo -o jsonpath='{.spec.ports[0].nodePort}')
    
    # Obtener puerto del backend
    BACKEND_PORT=$(kubectl get service ticketpardo-backend-service -n ticketpardo -o jsonpath='{.spec.ports[0].port}')
    
    echo -e "${GREEN}📍 URLs de acceso:${NC}"
    echo -e "${GREEN}   Frontend: http://$MINIKUBE_IP:$FRONTEND_PORT${NC}"
    echo -e "${GREEN}   Backend: Acceder via port-forward${NC}"
    echo ""
    
    echo -e "${YELLOW}🔧 Comandos útiles:${NC}"
    echo -e "${YELLOW}   Acceder al frontend:${NC}"
    echo -e "${YELLOW}     minikube service ticketpardo-frontend-service -n ticketpardo${NC}"
    echo ""
    echo -e "${YELLOW}   Port-forward para backend:${NC}"
    echo -e "${YELLOW}     kubectl port-forward service/ticketpardo-backend-service 8000:80 -n ticketpardo${NC}"
    echo ""
    echo -e "${YELLOW}   Ver logs:${NC}"
    echo -e "${YELLOW}     kubectl logs -f deployment/ticketpardo-backend -n ticketpardo${NC}"
    echo -e "${YELLOW}     kubectl logs -f deployment/ticketpardo-frontend -n ticketpardo${NC}"
    echo ""
    echo -e "${YELLOW}   Dashboard de Kubernetes:${NC}"
    echo -e "${YELLOW}     minikube dashboard${NC}"
    echo ""
    
    echo -e "${BLUE}📝 Para configurar acceso via dominio local:${NC}"
    echo -e "${BLUE}   1. Agrega a /etc/hosts (Linux/Mac) o C:\\Windows\\System32\\drivers\\etc\\hosts (Windows):${NC}"
    echo -e "${BLUE}      $MINIKUBE_IP ticketpardo.local${NC}"
    echo -e "${BLUE}   2. Accede a: http://ticketpardo.local${NC}"
}

# Función para abrir servicios automáticamente
open_services() {
    read -p "¿Quieres abrir la aplicación en el navegador? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}🌐 Abriendo aplicación...${NC}"
        minikube service ticketpardo-frontend-service -n ticketpardo
    fi
}

# Función principal
main() {
    check_tools
    check_minikube_status
    setup_docker_env
    build_images
    create_minikube_configs
    deploy_to_k8s
    verify_deployment
    show_access_info
    open_services
    
    echo -e "${GREEN}✨ ¡TicketPardo desplegado exitosamente en Minikube!${NC}"
}

# Ejecutar función principal
main
