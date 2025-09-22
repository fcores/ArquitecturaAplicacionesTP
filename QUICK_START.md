# 🚀 Inicio Rápido - TicketPardo en EC2 con Minikube

## 📝 Resumen

Esta guía te permite desplegar **TicketPardo** en una instancia EC2 de AWS con Minikube en menos de 15 minutos.

## 🎯 Pasos Rápidos

### 1. Preparar EC2
- Crear instancia EC2 (t3.medium recomendado)
- Ubuntu 20.04 LTS
- Security Group: puertos 22, 80, 443, 3000, 8000, 30000-32767

### 2. Conectar y Clonar
```bash
ssh -i tu-clave.pem ubuntu@TU_IP_EC2
git clone <URL_REPOSITORIO>
cd ArquitecturaAplicacionesTP
```

### 3. Desplegar
```bash
# Hacer scripts ejecutables
bash scripts/make-executable.sh

# Despliegue automático
bash scripts/quick-deploy.sh
```

### 4. Acceder
```bash
# Port-forward (en terminales separadas)
kubectl port-forward svc/ticketpardo-frontend-service 3000:80 -n ticketpardo
kubectl port-forward svc/ticketpardo-backend-service 8000:8000 -n ticketpardo
```

**URLs:**
- Frontend: http://TU_IP_EC2:3000
- Backend: http://TU_IP_EC2:8000/docs

## 🛠️ Comandos Útiles

```bash
# Monitorear
bash scripts/monitor.sh

# Ver logs
kubectl logs -f deployment/ticketpardo-backend -n ticketpardo

# Limpiar
bash scripts/cleanup.sh

# Usando Makefile
make help
make quick-deploy
make monitor
```

## 📁 Estructura de Archivos

```
📦 ArquitecturaAplicacionesTP/
├── 🐳 Docker
│   ├── Dockerfile.frontend (con proxy reverso)
│   ├── backend/Dockerfile
│   ├── docker-compose.yml
│   └── nginx.conf
├── ☸️ Kubernetes
│   └── k8s/
│       ├── namespace.yaml
│       ├── configmap.yaml
│       ├── backend-deployment.yaml
│       ├── backend-service.yaml
│       ├── frontend-deployment.yaml
│       ├── frontend-service.yaml
│       └── ingress.yaml
├── 🚀 Scripts
│   └── scripts/
│       ├── setup-ec2.sh
│       ├── deploy-minikube.sh
│       ├── build-images.sh
│       ├── quick-deploy.sh
│       ├── recomendacion-proxy.sh
│       ├── monitor.sh
│       ├── cleanup.sh
│       └── make-executable.sh
├── ⚙️ Configuración
│   └── Makefile
└── 📚 Documentación
    ├── DEPLOY_MINIKUBE.md
    ├── QUICK_START.md
    └── PROXY_REVERSO_SOLUTION.md
```

## ✅ ¡Listo!

Tu aplicación **TicketPardo** está corriendo en EC2 con Minikube y Kubernetes.

Para soporte completo, consulta [DEPLOY_MINIKUBE.md](./DEPLOY_MINIKUBE.md)
