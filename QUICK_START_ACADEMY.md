# ⚡ Inicio Rápido - AWS Academy

## 🎯 Dos opciones para desplegar TicketPardo

### 🏭 Opción 1: AWS Academy (Producción simulada)
### 🖥️ Opción 2: Minikube Local (Desarrollo)

---

## 🏭 OPCIÓN 1: AWS Academy (Recomendado)

### Paso 1: Preparar AWS Academy
1. **Inicia tu laboratorio en AWS Academy**
2. **Ve a "AWS Details" y copia las credenciales**
3. **Configura AWS CLI:**
   ```bash
   aws configure set aws_access_key_id TU_ACCESS_KEY
   aws configure set aws_secret_access_key TU_SECRET_KEY
   aws configure set aws_session_token TU_SESSION_TOKEN
   aws configure set region us-east-1
   ```

### Paso 2: Crear KeyPair
```bash
# Crear un key pair para SSH
aws ec2 create-key-pair --key-name ticketpardo-key --query 'KeyMaterial' --output text > ticketpardo-key.pem
chmod 400 ticketpardo-key.pem
```

### Paso 3: Desplegar con CloudFormation
```bash
# Desplegar la infraestructura
aws cloudformation create-stack \
  --stack-name ticketpardo-stack \
  --template-body file://cloudformation-academy.yml \
  --parameters ParameterKey=KeyPairName,ParameterValue=ticketpardo-key \
  --capabilities CAPABILITY_IAM

# Esperar a que complete (5-10 minutos)
aws cloudformation wait stack-create-complete --stack-name ticketpardo-stack
```

### Paso 4: Obtener IP de la instancia
```bash
# Obtener la IP pública
EC2_IP=$(aws cloudformation describe-stacks --stack-name ticketpardo-stack --query 'Stacks[0].Outputs[?OutputKey==`InstancePublicIP`].OutputValue' --output text)
echo "IP de tu instancia: $EC2_IP"
```

### Paso 5: Configurar variables de entorno
```bash
# Copiar archivo de ejemplo
cp env.production.example .env.production

# Editar con tu IP (reemplaza TU_EC2_IP con la IP real)
sed -i "s/tu-ec2-public-ip-aqui/$EC2_IP/g" .env.production
```

### Paso 6: Desplegar la aplicación
```bash
# Hacer ejecutable el script
chmod +x scripts/deploy-ec2.sh

# Desplegar (reemplaza TU_EC2_IP con la IP real)
./scripts/deploy-ec2.sh $EC2_IP ./ticketpardo-key.pem
```

### 🎉 ¡Listo! Accede a:
- **Frontend**: http://TU_EC2_IP
- **Backend API**: http://TU_EC2_IP:8000
- **API Docs**: http://TU_EC2_IP:8000/docs

---

## 🖥️ OPCIÓN 2: Minikube Local

### Paso 1: Instalar herramientas
```bash
# Windows (con Chocolatey)
choco install minikube kubernetes-cli docker-desktop

# O descargar manualmente:
# https://minikube.sigs.k8s.io/docs/start/
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

### Paso 2: Iniciar Minikube
```bash
# Iniciar Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Habilitar addons
minikube addons enable ingress
minikube addons enable metrics-server
```

### Paso 3: Desplegar aplicación
```bash
# Hacer ejecutable el script
chmod +x scripts/deploy-minikube.sh

# Desplegar
./scripts/deploy-minikube.sh
```

### Paso 4: Acceder a la aplicación
```bash
# Obtener URL del frontend
minikube service ticketpardo-frontend-service -n ticketpardo --url

# Port-forward para el backend
kubectl port-forward service/ticketpardo-backend-service 8000:80 -n ticketpardo
```

### 🎉 ¡Listo! Accede a:
- **Frontend**: URL que devuelve el comando `minikube service`
- **Backend API**: http://localhost:8000 (con port-forward activo)
- **Dashboard K8s**: `minikube dashboard`

---

## 🔧 Comandos Útiles

### AWS Academy:
```bash
# Conectar por SSH
ssh -i ticketpardo-key.pem ec2-user@TU_EC2_IP

# Ver logs
ssh -i ticketpardo-key.pem ec2-user@TU_EC2_IP 'cd /opt/ticketpardo && docker-compose -f docker-compose.prod.yml logs -f'

# Reiniciar aplicación
ssh -i ticketpardo-key.pem ec2-user@TU_EC2_IP 'cd /opt/ticketpardo && docker-compose -f docker-compose.prod.yml restart'
```

### Minikube:
```bash
# Ver estado de pods
kubectl get pods -n ticketpardo

# Ver logs
kubectl logs -f deployment/ticketpardo-backend -n ticketpardo

# Parar Minikube
minikube stop

# Eliminar cluster
minikube delete
```

---

## ❓ ¿Cuál elegir?

### ✅ **AWS Academy** si:
- Quieres simular un entorno de producción
- Necesitas acceso desde internet
- Quieres aprender AWS
- Tienes créditos de Academy disponibles

### ✅ **Minikube** si:
- Quieres desarrollo local rápido
- Quieres aprender Kubernetes
- No tienes limitaciones de créditos
- Prefieres no depender de internet

---

## 🆘 Problemas Comunes

### AWS Academy:
- **Credenciales expiradas**: Reinicia el lab y reconfigura AWS CLI
- **Límite de instancias**: Verifica que no tengas otras instancias corriendo
- **SSH no funciona**: Verifica que el Security Group permita puerto 22

### Minikube:
- **Docker no inicia**: Asegúrate de que Docker Desktop esté corriendo
- **Recursos insuficientes**: Aumenta memoria/CPU en el comando start
- **Imágenes no se encuentran**: Verifica que `eval $(minikube docker-env)` esté ejecutado

---

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs con los comandos de arriba
2. Consulta la documentación completa en `AWS_ACADEMY_DEPLOYMENT.md`
3. Verifica que todas las herramientas estén instaladas correctamente

¡Buena suerte con tu despliegue! 🚀
