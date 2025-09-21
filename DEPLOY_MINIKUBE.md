# 🚀 Guía de Despliegue en EC2 con Minikube

Esta guía te permitirá desplegar **TicketPardo** en una instancia EC2 de AWS utilizando Minikube para orquestación con Kubernetes.

## 📋 Prerrequisitos

### AWS EC2
- Instancia EC2 (recomendado: t3.medium o superior)
- Ubuntu 20.04 LTS o superior
- Al menos 4GB RAM y 20GB de espacio en disco
- Security Group configurado con los siguientes puertos:
  - **22** (SSH)
  - **80** (HTTP)
  - **443** (HTTPS)
  - **3000** (Frontend React)
  - **8000** (Backend FastAPI)
  - **30000-32767** (NodePort range de Kubernetes)

### Acceso
- Clave SSH para conectarse a la instancia
- Usuario con permisos sudo

## 🛠️ Instalación Automática

### Método 1: Despliegue Rápido (Recomendado)

```bash
# 1. Conectarse a la instancia EC2
ssh -i tu-clave.pem ubuntu@TU_IP_EC2

# 2. Clonar el repositorio
git clone <URL_DEL_REPOSITORIO>
cd ArquitecturaAplicacionesTP

# 3. Ejecutar despliegue automático
bash scripts/quick-deploy.sh
```

**Nota**: En la primera ejecución, el script configurará todo el sistema. Será necesario reiniciar la sesión SSH o ejecutar `newgrp docker` antes de continuar.

### Método 2: Paso a Paso

```bash
# 1. Configurar el sistema
bash scripts/setup-ec2.sh

# 2. Reiniciar sesión SSH o ejecutar
newgrp docker

# 3. Construir imágenes
bash scripts/build-images.sh

# 4. Desplegar en Minikube
bash scripts/deploy-minikube.sh
```

## 🎯 Verificación del Despliegue

### Verificar Estado
```bash
# Monitorear el estado general
bash scripts/monitor.sh

# Verificar pods
kubectl get pods -n ticketpardo

# Ver logs
kubectl logs -f deployment/ticketpardo-backend -n ticketpardo
kubectl logs -f deployment/ticketpardo-frontend -n ticketpardo
```

### Acceso a la Aplicación

#### Opción 1: Port Forward (Recomendado para desarrollo)
```bash
# Frontend
kubectl port-forward svc/ticketpardo-frontend-service 3000:80 -n ticketpardo

# Backend (en otra terminal)
kubectl port-forward svc/ticketpardo-backend-service 8000:8000 -n ticketpardo
```

Luego accede a:
- **Frontend**: http://TU_IP_EC2:3000
- **Backend API**: http://TU_IP_EC2:8000
- **API Docs**: http://TU_IP_EC2:8000/docs

#### Opción 2: NodePort (Para producción)
```bash
# Obtener puertos asignados
kubectl get svc -n ticketpardo

# Acceder directamente
# Frontend: http://TU_IP_EC2:NODEPORT_FRONTEND
# Backend: http://TU_IP_EC2:NODEPORT_BACKEND
```

## 🔧 Comandos Útiles

### Minikube
```bash
# Ver estado
minikube status

# Dashboard web
minikube dashboard --url

# Obtener IP
minikube ip

# Parar/Iniciar
minikube stop
minikube start
```

### Kubernetes
```bash
# Ver todos los recursos
kubectl get all -n ticketpardo

# Escalar servicios
kubectl scale deployment ticketpardo-backend --replicas=3 -n ticketpardo

# Reiniciar despliegue
kubectl rollout restart deployment/ticketpardo-backend -n ticketpardo

# Ver eventos
kubectl get events -n ticketpardo --sort-by='.lastTimestamp'
```

### Docker
```bash
# Ver imágenes
docker images | grep ticketpardo

# Ver contenedores
docker ps

# Reconstruir imágenes
bash scripts/build-images.sh
```

## 🛡️ Configuración de Seguridad

### Firewall (UFW)
```bash
# Ver estado
sudo ufw status

# Permitir puertos adicionales si es necesario
sudo ufw allow 8080/tcp
```

### Variables de Entorno
```bash
# Copiar y editar variables de producción
cp env.production .env
nano .env
```

## 📊 Monitoreo y Logs

### Logs en Tiempo Real
```bash
# Backend
kubectl logs -f deployment/ticketpardo-backend -n ticketpardo

# Frontend
kubectl logs -f deployment/ticketpardo-frontend -n ticketpardo

# Todos los pods
kubectl logs -f -l app=ticketpardo-backend -n ticketpardo
```

### Métricas
```bash
# Uso de recursos
kubectl top pods -n ticketpardo
kubectl top nodes
```

## 🧹 Limpieza

### Limpiar Recursos
```bash
# Limpieza automática
bash scripts/cleanup.sh

# Limpieza manual
kubectl delete namespace ticketpardo
minikube delete
```

## ❗ Solución de Problemas

### Problema: Docker requiere sudo
```bash
# Solución
newgrp docker
# o
sudo usermod -aG docker $USER
# luego reiniciar sesión
```

### Problema: Pods en estado Pending
```bash
# Verificar recursos
kubectl describe pod <POD_NAME> -n ticketpardo
kubectl top nodes
```

### Problema: Imágenes no se encuentran
```bash
# Reconstruir imágenes
eval $(minikube docker-env)
bash scripts/build-images.sh
```

### Problema: Servicios no responden
```bash
# Verificar endpoints
kubectl get endpoints -n ticketpardo

# Reiniciar servicios
kubectl rollout restart deployment/ticketpardo-backend -n ticketpardo
kubectl rollout restart deployment/ticketpardo-frontend -n ticketpardo
```

## 📈 Escalabilidad

### Escalar Horizontalmente
```bash
# Escalar backend
kubectl scale deployment ticketpardo-backend --replicas=3 -n ticketpardo

# Escalar frontend
kubectl scale deployment ticketpardo-frontend --replicas=2 -n ticketpardo
```

### Configurar Auto-scaling
```bash
# HPA para backend
kubectl autoscale deployment ticketpardo-backend --cpu-percent=70 --min=2 --max=10 -n ticketpardo
```

## 🔄 Actualizaciones

### Actualizar Aplicación
```bash
# 1. Hacer pull del código actualizado
git pull origin main

# 2. Reconstruir imágenes
bash scripts/build-images.sh

# 3. Reiniciar despliegues
kubectl rollout restart deployment/ticketpardo-backend -n ticketpardo
kubectl rollout restart deployment/ticketpardo-frontend -n ticketpardo
```

## 🎉 ¡Listo!

Tu aplicación **TicketPardo** debería estar corriendo exitosamente en EC2 con Minikube. 

Para soporte adicional, revisa los logs y usa el script de monitoreo:
```bash
bash scripts/monitor.sh
```
