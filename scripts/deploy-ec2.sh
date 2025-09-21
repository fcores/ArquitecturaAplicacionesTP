#!/bin/bash

# Script para desplegar TicketPardo en EC2 (AWS Academy)
# Uso: ./scripts/deploy-ec2.sh [EC2_IP]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
EC2_IP=${1:-""}
KEY_PATH=${2:-"~/.ssh/ticketpardo-key.pem"}
EC2_USER="ec2-user"

echo -e "${BLUE}🚀 Desplegando TicketPardo en AWS Academy EC2${NC}"
echo -e "${BLUE}============================================${NC}"

# Función para verificar parámetros
check_parameters() {
    if [ -z "$EC2_IP" ]; then
        echo -e "${RED}❌ Error: IP de EC2 requerida${NC}"
        echo -e "${YELLOW}Uso: ./scripts/deploy-ec2.sh <EC2_IP> [KEY_PATH]${NC}"
        echo -e "${YELLOW}Ejemplo: ./scripts/deploy-ec2.sh 54.123.45.67${NC}"
        exit 1
    fi
    
    if [ ! -f "$KEY_PATH" ]; then
        echo -e "${RED}❌ Error: Key file no encontrado en $KEY_PATH${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Parámetros verificados${NC}"
    echo -e "${GREEN}   IP EC2: $EC2_IP${NC}"
    echo -e "${GREEN}   Key Path: $KEY_PATH${NC}"
}

# Función para preparar archivos locales
prepare_local_files() {
    echo -e "${YELLOW}📦 Preparando archivos locales...${NC}"
    
    # Crear archivo .env.production si no existe
    if [ ! -f ".env.production" ]; then
        cp .env.production.example .env.production
        sed -i "s/tu-ec2-public-ip-aqui/$EC2_IP/g" .env.production
        echo -e "${YELLOW}⚠️ Archivo .env.production creado. Por favor revisa y actualiza las variables${NC}"
    fi
    
    # Crear directorio temporal para el despliegue
    mkdir -p /tmp/ticketpardo-deploy
    
    # Copiar archivos necesarios
    cp -r . /tmp/ticketpardo-deploy/
    cd /tmp/ticketpardo-deploy
    
    # Limpiar archivos innecesarios
    rm -rf node_modules .git logs
    
    echo -e "${GREEN}✅ Archivos preparados${NC}"
}

# Función para verificar conexión SSH
test_ssh_connection() {
    echo -e "${YELLOW}🔍 Verificando conexión SSH...${NC}"
    
    if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" "echo 'SSH connection successful'" &> /dev/null; then
        echo -e "${GREEN}✅ Conexión SSH exitosa${NC}"
    else
        echo -e "${RED}❌ Error: No se puede conectar via SSH${NC}"
        echo -e "${YELLOW}Verifica:${NC}"
        echo -e "${YELLOW}  - La IP de EC2 es correcta${NC}"
        echo -e "${YELLOW}  - El archivo de clave es correcto${NC}"
        echo -e "${YELLOW}  - El Security Group permite SSH (puerto 22)${NC}"
        exit 1
    fi
}

# Función para configurar el servidor EC2
setup_ec2_server() {
    echo -e "${YELLOW}⚙️ Configurando servidor EC2...${NC}"
    
    ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" << 'EOF'
        set -e
        
        echo "📦 Actualizando sistema..."
        sudo yum update -y
        
        echo "🐳 Instalando Docker..."
        sudo yum install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker ec2-user
        
        echo "🔧 Instalando Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        echo "📁 Creando directorios..."
        mkdir -p /home/ec2-user/ticketpardo
        mkdir -p /home/ec2-user/ticketpardo/logs
        
        echo "✅ Servidor configurado"
EOF
    
    echo -e "${GREEN}✅ Servidor EC2 configurado${NC}"
}

# Función para subir archivos
upload_files() {
    echo -e "${YELLOW}📤 Subiendo archivos a EC2...${NC}"
    
    # Comprimir archivos para transferencia más rápida
    tar -czf ticketpardo-app.tar.gz -C /tmp/ticketpardo-deploy .
    
    # Subir archivo comprimido
    scp -i "$KEY_PATH" -o StrictHostKeyChecking=no ticketpardo-app.tar.gz "$EC2_USER@$EC2_IP:/home/ec2-user/"
    
    # Extraer en el servidor
    ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" << 'EOF'
        cd /home/ec2-user/ticketpardo
        tar -xzf ../ticketpardo-app.tar.gz
        rm ../ticketpardo-app.tar.gz
        ls -la
EOF
    
    echo -e "${GREEN}✅ Archivos subidos${NC}"
}

# Función para desplegar la aplicación
deploy_application() {
    echo -e "${YELLOW}🚀 Desplegando aplicación...${NC}"
    
    ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no "$EC2_USER@$EC2_IP" << 'EOF'
        cd /home/ec2-user/ticketpardo
        
        echo "🐳 Iniciando servicios con Docker Compose..."
        
        # Cargar variables de entorno
        export $(cat .env.production | xargs)
        
        # Construir y ejecutar contenedores
        docker-compose -f docker-compose.prod.yml down || true
        docker-compose -f docker-compose.prod.yml up -d --build
        
        echo "⏳ Esperando a que los servicios estén listos..."
        sleep 30
        
        echo "📊 Estado de los contenedores:"
        docker-compose -f docker-compose.prod.yml ps
        
        echo "🔍 Verificando salud de la aplicación..."
        curl -f http://localhost:8000/ || echo "Backend aún iniciando..."
        curl -f http://localhost/ || echo "Frontend aún iniciando..."
EOF
    
    echo -e "${GREEN}✅ Aplicación desplegada${NC}"
}

# Función para mostrar información final
show_final_info() {
    echo -e "${BLUE}🎉 ¡Despliegue completado exitosamente!${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo ""
    echo -e "${GREEN}📍 URLs de acceso:${NC}"
    echo -e "${GREEN}   Frontend: http://$EC2_IP${NC}"
    echo -e "${GREEN}   Backend API: http://$EC2_IP:8000${NC}"
    echo -e "${GREEN}   API Docs: http://$EC2_IP:8000/docs${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Comandos útiles:${NC}"
    echo -e "${YELLOW}   SSH: ssh -i $KEY_PATH $EC2_USER@$EC2_IP${NC}"
    echo -e "${YELLOW}   Logs: ssh -i $KEY_PATH $EC2_USER@$EC2_IP 'cd ticketpardo && docker-compose -f docker-compose.prod.yml logs -f'${NC}"
    echo -e "${YELLOW}   Restart: ssh -i $KEY_PATH $EC2_USER@$EC2_IP 'cd ticketpardo && docker-compose -f docker-compose.prod.yml restart'${NC}"
    echo ""
    echo -e "${BLUE}📝 Próximos pasos:${NC}"
    echo -e "${BLUE}   1. Configura un dominio en Route53 (opcional)${NC}"
    echo -e "${BLUE}   2. Configura un Load Balancer para alta disponibilidad${NC}"
    echo -e "${BLUE}   3. Configura backups automáticos de la base de datos${NC}"
}

# Función de limpieza
cleanup() {
    echo -e "${YELLOW}🧹 Limpiando archivos temporales...${NC}"
    rm -rf /tmp/ticketpardo-deploy
    rm -f ticketpardo-app.tar.gz
}

# Función principal
main() {
    check_parameters
    prepare_local_files
    test_ssh_connection
    setup_ec2_server
    upload_files
    deploy_application
    show_final_info
    cleanup
}

# Manejo de errores
trap cleanup EXIT

# Ejecutar función principal
main
