#!/bin/bash
# Script que implementa la recomendación exacta proporcionada

set -e

echo "🔄 Aplicando recomendación de proxy reverso..."

cd ~/ArquitecturaAplicacionesTP || cd .

# Dockerfile con build-arg REACT_APP_API_URL
cat > Dockerfile.frontend <<'EOF'
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL
COPY src/ ./src/
COPY public/ ./public/
RUN REACT_APP_API_URL=$REACT_APP_API_URL npm run build
FROM nginx:1.25-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
EOF

echo "✅ Dockerfile.frontend actualizado"

# Build dentro del daemon de Minikube
echo "🐳 Configurando Docker environment de Minikube..."
eval $(minikube docker-env)

echo "🏗️ Construyendo imagen con proxy reverso..."
docker build -t ticketpardo-frontend:latest -f Dockerfile.frontend --build-arg REACT_APP_API_URL=/api .

echo "🔄 Reiniciando deployment..."
kubectl rollout restart deployment/ticketpardo-frontend -n ticketpardo

echo "⏳ Esperando deployment..."
kubectl wait --for=condition=ready pod -l app=ticketpardo-frontend -n ticketpardo --timeout=120s

echo "🔍 Verificación final..."
sleep 10
kubectl exec -n ticketpardo deployment/ticketpardo-frontend -- sh -c 'grep -R "localhost:8000" /usr/share/nginx/html || echo "✅ OK: sin localhost"'

echo "✅ ¡Recomendación aplicada exitosamente!"
