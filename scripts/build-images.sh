#!/bin/bash
# Script para construir las imágenes Docker de TicketPardo

set -e

echo "🏗️ Construyendo imágenes Docker para TicketPardo..."

# Verificar que estamos en el directorio correcto
if [ ! -f "package.json" ] || [ ! -f "backend/main.py" ]; then
    echo "❌ Error: Ejecuta este script desde el directorio raíz del proyecto"
    exit 1
fi

# Configurar variables
IMAGE_TAG=${IMAGE_TAG:-latest}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-localhost:5000}

echo "📋 Configuración:"
echo "   Tag: $IMAGE_TAG"
echo "   Registry: $DOCKER_REGISTRY"
echo "   API URL: /api (proxy reverso)"

# Construir imagen del backend
echo ""
echo "📦 Construyendo imagen del backend..."
docker build \
    -t ticketpardo-backend:$IMAGE_TAG \
    -t $DOCKER_REGISTRY/ticketpardo-backend:$IMAGE_TAG \
    -f backend/Dockerfile \
    ./backend/

echo "✅ Backend construido exitosamente"

# Construir imagen del frontend con proxy reverso
echo ""
echo "🌐 Construyendo imagen del frontend..."
docker build \
    --build-arg REACT_APP_API_URL="/api" \
    -t ticketpardo-frontend:$IMAGE_TAG \
    -t $DOCKER_REGISTRY/ticketpardo-frontend:$IMAGE_TAG \
    -f Dockerfile.frontend \
    .

echo "✅ Frontend construido exitosamente"

# Mostrar imágenes construidas
echo ""
echo "📋 Imágenes construidas:"
docker images | grep ticketpardo

# Opcional: Push al registry si está configurado
if [ "$PUSH_IMAGES" = "true" ]; then
    echo ""
    echo "📤 Subiendo imágenes al registry..."
    docker push $DOCKER_REGISTRY/ticketpardo-backend:$IMAGE_TAG
    docker push $DOCKER_REGISTRY/ticketpardo-frontend:$IMAGE_TAG
    echo "✅ Imágenes subidas exitosamente"
fi

echo ""
echo "✅ ¡Construcción completada!"
echo ""
echo "🚀 Próximos pasos:"
echo "   - Para desarrollo local: docker-compose up"
echo "   - Para Minikube: bash scripts/deploy-minikube.sh"
echo "   - Para subir al registry: PUSH_IMAGES=true bash scripts/build-images.sh"
