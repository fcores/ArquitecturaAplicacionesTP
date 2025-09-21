# 🎓 Despliegue de TicketPardo en AWS Academy

Esta guía está adaptada específicamente para las limitaciones de AWS Academy, usando solo los servicios disponibles.

## 📋 Servicios AWS Academy Disponibles para Nuestro Proyecto

✅ **Servicios que usaremos:**
- Amazon EC2 (t2.micro, t2.small, t3.micro, t3.small)
- Elastic Load Balancing
- Amazon RDS (PostgreSQL db.t3.micro)
- Amazon S3
- CloudFormation
- Route53 (sin registro de dominio)
- CloudWatch
- Auto Scaling

❌ **Servicios NO disponibles:**
- Amazon EKS (Kubernetes gestionado)
- ECR (Container Registry)
- Instancias grandes

## 🚀 Estrategia de Despliegue Adaptada

### Opción 1: EC2 + Docker Compose (Recomendado para Academy)
### Opción 2: Minikube Local + Túnel (Para desarrollo)

---

## 🏗️ OPCIÓN 1: Despliegue en EC2 con Docker Compose

### Paso 1: Preparar la aplicación

#### 1.1 Crear archivo docker-compose para producción
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://ticketpardo:${DB_PASSWORD}@db:5432/ticketpardo
      - SECRET_KEY=${SECRET_KEY}
      - DEBUG=false
    depends_on:
      - db
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    ports:
      - "80:80"
    depends_on:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=ticketpardo
      - POSTGRES_USER=ticketpardo
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ticketpardo"]
      interval: 30s
      timeout: 10s
      retries: 5

volumes:
  postgres_data:
```

#### 1.2 Crear archivo de variables de entorno
```bash
# .env.production
SECRET_KEY=tu-clave-secreta-super-segura-cambia-esto
DB_PASSWORD=password-seguro-de-base-de-datos
NODE_ENV=production
REACT_APP_API_URL=http://tu-ec2-ip:8000
```

### Paso 2: Crear instancia EC2

#### 2.1 Script de CloudFormation
```yaml
# cloudformation-template.yml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'TicketPardo Application Infrastructure'

Parameters:
  InstanceType:
    Type: String
    Default: t3.small
    AllowedValues: [t2.micro, t2.small, t3.micro, t3.small, t3.medium]
    Description: EC2 instance type
  
  KeyPairName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Name of an existing EC2 KeyPair

Resources:
  # Security Group
  TicketPardoSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group for TicketPardo application
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 8000
          ToPort: 8000
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  # EC2 Instance
  TicketPardoInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1d0  # Amazon Linux 2
      InstanceType: !Ref InstanceType
      KeyName: !Ref KeyPairName
      SecurityGroups:
        - !Ref TicketPardoSecurityGroup
      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          
          # Instalar Docker
          yum install -y docker
          systemctl start docker
          systemctl enable docker
          usermod -aG docker ec2-user
          
          # Instalar Docker Compose
          curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          chmod +x /usr/local/bin/docker-compose
          
          # Instalar Git
          yum install -y git
          
          # Crear directorio para la aplicación
          mkdir -p /opt/ticketpardo
          chown ec2-user:ec2-user /opt/ticketpardo

Outputs:
  InstancePublicIP:
    Description: Public IP address of the EC2 instance
    Value: !GetAtt TicketPardoInstance.PublicIp
  
  InstancePublicDNS:
    Description: Public DNS name of the EC2 instance
    Value: !GetAtt TicketPardoInstance.PublicDnsName
```

### Paso 3: Scripts de despliegue

#### 3.1 Script de setup en EC2
```bash
#!/bin/bash
# setup-ec2.sh

echo "🚀 Configurando TicketPardo en EC2"

# Variables
REPO_URL="https://github.com/tu-usuario/ticketpardo.git"
APP_DIR="/opt/ticketpardo"

# Clonar repositorio
cd $APP_DIR
git clone $REPO_URL .

# Configurar variables de entorno
cp .env.production .env

# Construir y ejecutar con Docker Compose
docker-compose -f docker-compose.prod.yml up -d --build

echo "✅ TicketPardo desplegado exitosamente"
echo "🌐 Frontend: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "🔧 Backend API: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000"
```

---

## 🖥️ OPCIÓN 2: Minikube Local (Desarrollo y Testing)

### Paso 1: Instalar Minikube en Windows

#### 1.1 Instalar herramientas
```powershell
# Instalar Chocolatey (si no lo tienes)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Instalar Minikube y kubectl
choco install minikube
choco install kubernetes-cli

# O descargar manualmente:
# https://minikube.sigs.k8s.io/docs/start/
```

#### 1.2 Iniciar Minikube
```bash
# Iniciar Minikube con configuración optimizada
minikube start --driver=docker --memory=4096 --cpus=2

# Habilitar addons necesarios
minikube addons enable ingress
minikube addons enable metrics-server
minikube addons enable dashboard
```

### Paso 2: Adaptar configuraciones para Minikube

#### 2.1 Configurar variables para desarrollo local
```bash
# Configurar Docker environment para usar Minikube
minikube docker-env
# Ejecutar el comando que te devuelve para configurar tu shell
```

#### 2.2 Construir imágenes en Minikube
```bash
# Configurar Docker para usar el daemon de Minikube
eval $(minikube docker-env)

# Construir imágenes
docker build -t ticketpardo-backend:local ./backend
docker build -f Dockerfile.frontend -t ticketpardo-frontend:local .
```

### Paso 3: Desplegar en Minikube

#### 3.1 Actualizar archivos k8s para Minikube
```yaml
# k8s/minikube/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ticketpardo-backend
  namespace: ticketpardo
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
        imagePullPolicy: Never  # Importante para Minikube
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          value: "sqlite:///./tickets.db"  # Usar SQLite para simplicidad
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

#### 3.2 Script de despliegue para Minikube
```bash
#!/bin/bash
# deploy-minikube.sh

echo "🚀 Desplegando TicketPardo en Minikube"

# Configurar Docker environment
eval $(minikube docker-env)

# Construir imágenes
echo "🐳 Construyendo imágenes..."
docker build -t ticketpardo-backend:local ./backend
docker build -f Dockerfile.frontend -t ticketpardo-frontend:local .

# Aplicar configuraciones
echo "⚙️ Aplicando configuraciones de Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/minikube/

# Esperar a que los pods estén listos
echo "⏳ Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=ticketpardo-backend -n ticketpardo --timeout=300s
kubectl wait --for=condition=ready pod -l app=ticketpardo-frontend -n ticketpardo --timeout=300s

# Obtener URL de la aplicación
echo "✅ Despliegue completado"
echo "🌐 Para acceder a la aplicación:"
echo "   minikube service ticketpardo-frontend-service -n ticketpardo --url"

# Abrir dashboard de Kubernetes
echo "📊 Para ver el dashboard:"
echo "   minikube dashboard"
```

---

## 📝 Instrucciones Paso a Paso

### Para AWS Academy (EC2 + Docker Compose):

1. **Crear KeyPair en EC2**
2. **Desplegar CloudFormation template**
3. **Conectar a la instancia EC2**
4. **Ejecutar script de setup**
5. **Configurar Load Balancer (opcional)**

### Para Minikube Local:

1. **Instalar Minikube y Docker**
2. **Iniciar Minikube**
3. **Ejecutar script de despliegue**
4. **Acceder via port-forward o ingress**

---

## 🔧 Comandos Útiles

### AWS Academy:
```bash
# Conectar a EC2
ssh -i tu-key.pem ec2-user@tu-ec2-ip

# Ver logs de la aplicación
docker-compose -f docker-compose.prod.yml logs -f

# Reiniciar servicios
docker-compose -f docker-compose.prod.yml restart
```

### Minikube:
```bash
# Ver estado
kubectl get pods -n ticketpardo

# Ver logs
kubectl logs -f deployment/ticketpardo-backend -n ticketpardo

# Acceder a la aplicación
minikube service ticketpardo-frontend-service -n ticketpardo

# Parar Minikube
minikube stop
```

---

## 💡 Recomendación

**Para AWS Academy**: Usa la Opción 1 (EC2 + Docker Compose) ya que es más simple y se adapta a las limitaciones.

**Para desarrollo local**: Usa la Opción 2 (Minikube) para aprender Kubernetes sin limitaciones.

¿Con cuál opción quieres empezar? 🤔
