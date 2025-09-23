# 🚀 TicketPardo - Deployment en AWS EC2

## 📋 Requisitos Previos

### En tu EC2 Instance:
- Ubuntu 20.04+ o Amazon Linux 2
- Docker instalado y funcionando
- Minikube instalado
- kubectl instalado
- Git instalado

## 🛠️ Setup Inicial en EC2

### 1. Instalar dependencias
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Instalar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Reiniciar sesión para aplicar cambios de grupo
newgrp docker
```

### 2. Configurar Security Groups en AWS
Abrir los siguientes puertos en el Security Group:
- **Puerto 22**: SSH
- **Puerto 30080**: Frontend (NodePort)
- **Puerto 30000-32767**: Rango de NodePorts de Kubernetes

## 🚀 Deployment

### 1. Clonar el repositorio
```bash
git clone <tu-repositorio>
cd ArquitecturaAplicacionesTP
```

### 2. Ejecutar deployment
```bash
# Con IP pública específica
./deploy-aws.sh YOUR_PUBLIC_IP

# O sin IP específica (usará configuración por defecto)
./deploy-aws.sh
```

### 3. Verificar deployment
```bash
# Ver estado de los pods
kubectl get pods -n ticketpardo

# Ver servicios y puertos
kubectl get svc -n ticketpardo

# Ver logs
kubectl logs -f deployment/backend -n ticketpardo
kubectl logs -f deployment/frontend -n ticketpardo
```

## 🌐 URLs de Acceso

Una vez deployado, tu aplicación estará disponible en:

- **Frontend**: `http://YOUR_PUBLIC_IP:30080`
- **Backend API**: `http://YOUR_PUBLIC_IP:30000`
- **API Docs**: `http://YOUR_PUBLIC_IP:30000/api/docs`

## 🔧 Configuración de Variables de Entorno

### Para producción, editar `env.production`:
```bash
ENVIRONMENT=production
CORS_ORIGINS=*
PUBLIC_IP=YOUR_PUBLIC_IP
REACT_APP_API_URL=/api
```

## 📊 Monitoreo y Mantenimiento

### Comandos útiles:
```bash
# Ver estado general
kubectl get all -n ticketpardo

# Escalar servicios
kubectl scale deployment backend --replicas=3 -n ticketpardo
kubectl scale deployment frontend --replicas=2 -n ticketpardo

# Actualizar imágenes
kubectl rollout restart deployment/backend -n ticketpardo
kubectl rollout restart deployment/frontend -n ticketpardo

# Ver logs en tiempo real
kubectl logs -f -l app=backend -n ticketpardo
kubectl logs -f -l app=frontend -n ticketpardo

# Acceder a un pod
kubectl exec -it deployment/backend -n ticketpardo -- /bin/bash
```

### Health Checks:
```bash
# Backend health
curl http://YOUR_PUBLIC_IP:30000/api/healthz

# Frontend health  
curl http://YOUR_PUBLIC_IP:30080/health
```

## 🐛 Troubleshooting

### Si los pods no inician:
```bash
# Ver eventos
kubectl describe pod -l app=backend -n ticketpardo
kubectl describe pod -l app=frontend -n ticketpardo

# Ver logs detallados
kubectl logs -l app=backend -n ticketpardo --previous
```

### Si hay problemas de CORS:
1. Verificar que `PUBLIC_IP` esté configurada correctamente
2. Revisar logs del backend para errores de CORS
3. Verificar que el Security Group permita el tráfico

### Si Minikube no inicia:
```bash
# Reiniciar Minikube
minikube delete
minikube start --driver=docker

# Verificar recursos
minikube status
docker system df
```

## 🔄 Actualización de la Aplicación

```bash
# 1. Hacer cambios en el código
# 2. Rebuild y redeploy
./deploy-aws.sh YOUR_PUBLIC_IP

# O manualmente:
eval $(minikube docker-env)
docker build -t ticketpardo-backend:latest -f backend/Dockerfile ./backend
docker build -t ticketpardo-frontend:latest -f Dockerfile.frontend .
kubectl rollout restart deployment/backend -n ticketpardo
kubectl rollout restart deployment/frontend -n ticketpardo
```

## 🛡️ Seguridad

### Recomendaciones:
1. **Firewall**: Configurar iptables o ufw
2. **SSL/TLS**: Usar Let's Encrypt con nginx-ingress
3. **Secrets**: Usar Kubernetes secrets para datos sensibles
4. **Updates**: Mantener sistema actualizado

### Configurar SSL (opcional):
```bash
# Instalar cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Configurar Let's Encrypt issuer
# (requiere dominio configurado)
```

## 📈 Escalabilidad

### Para manejar más tráfico:
```bash
# Escalar backend
kubectl scale deployment backend --replicas=5 -n ticketpardo

# Escalar frontend
kubectl scale deployment frontend --replicas=3 -n ticketpardo

# Auto-scaling (opcional)
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10 -n ticketpardo
```

## 📞 Soporte

Si encuentras problemas:
1. Revisar logs: `kubectl logs -f deployment/backend -n ticketpardo`
2. Verificar estado: `kubectl get pods -n ticketpardo`
3. Revisar configuración: `kubectl describe deployment backend -n ticketpardo`
