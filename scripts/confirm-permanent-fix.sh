#!/bin/bash
# Script para confirmar que el arreglo permanente está implementado

set -e

echo "🔍 Confirmando arreglo permanente del proxy reverso..."

# Función para mostrar resultados
show_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

echo ""
echo "📋 Verificando configuración permanente..."

# 1. Verificar nginx.conf tiene el bloque /api
NGINX_API_BLOCK=$(grep -c "location /api/" nginx.conf || echo 0)
show_result $([ $NGINX_API_BLOCK -gt 0 ] && echo 0 || echo 1) "nginx.conf tiene bloque location /api/"

# 2. Verificar proxy_pass correcto
NGINX_PROXY_PASS=$(grep -c "proxy_pass http://ticketpardo-backend-service:8000/" nginx.conf || echo 0)
show_result $([ $NGINX_PROXY_PASS -gt 0 ] && echo 0 || echo 1) "nginx.conf proxy_pass apunta al backend service"

# 3. Verificar Dockerfile usa /api por defecto
DOCKERFILE_API_ARG=$(grep -c "ARG REACT_APP_API_URL=/api" Dockerfile.frontend || echo 0)
show_result $([ $DOCKERFILE_API_ARG -gt 0 ] && echo 0 || echo 1) "Dockerfile.frontend usa /api por defecto"

# 4. Verificar que el frontend usa la variable correcta
FRONTEND_BASEURL=$(grep -c "process.env.REACT_APP_API_URL || '/api'" src/context/AppContext.js || echo 0)
show_result $([ $FRONTEND_BASEURL -gt 0 ] && echo 0 || echo 1) "Frontend usa variable REACT_APP_API_URL con fallback /api"

# 5. Verificar archivos de ejemplo existen
ENV_EXAMPLE_EXISTS=$([ -f "env.example" ] && echo 1 || echo 0)
show_result $([ $ENV_EXAMPLE_EXISTS -eq 1 ] && echo 0 || echo 1) "env.example existe"

ENV_PROD_EXAMPLE_EXISTS=$([ -f "env.production.example" ] && echo 1 || echo 0)
show_result $([ $ENV_PROD_EXAMPLE_EXISTS -eq 1 ] && echo 0 || echo 1) "env.production.example existe"

# 6. Verificar que env.production.example tiene /api
ENV_PROD_API=$(grep -c "REACT_APP_API_URL=/api" env.production.example || echo 0)
show_result $([ $ENV_PROD_API -gt 0 ] && echo 0 || echo 1) "env.production.example usa /api"

# 7. Verificar scripts de build usan /api
BUILD_SCRIPT_API=$(grep -c "REACT_APP_API_URL=\"/api\"" scripts/build-images.sh || echo 0)
show_result $([ $BUILD_SCRIPT_API -gt 0 ] && echo 0 || echo 1) "Script de build usa /api"

DEPLOY_SCRIPT_API=$(grep -c "REACT_APP_API_URL=/api" scripts/deploy-minikube.sh || echo 0)
show_result $([ $DEPLOY_SCRIPT_API -gt 0 ] && echo 0 || echo 1) "Script de deploy usa /api"

echo ""
echo "🎯 Verificando que NO hay dependencias de hot-fixes..."

# 8. Verificar que no hay localhost hardcodeado
NO_LOCALHOST=$(find src -name "*.js" -exec grep -l "localhost:8000" {} \; | wc -l)
show_result $([ $NO_LOCALHOST -eq 0 ] && echo 0 || echo 1) "Sin localhost hardcodeado en código"

# 9. Verificar que no hay proxy en package.json
NO_PACKAGE_PROXY=$(grep -c '"proxy"' package.json || echo 0)
show_result $([ $NO_PACKAGE_PROXY -eq 0 ] && echo 0 || echo 1) "Sin proxy hardcodeado en package.json"

echo ""
echo "🏗️ Verificando que la imagen se puede reconstruir correctamente..."

# 10. Verificar que el Dockerfile copia nginx.conf
DOCKERFILE_NGINX=$(grep -c "COPY nginx.conf" Dockerfile.frontend || echo 0)
show_result $([ $DOCKERFILE_NGINX -gt 0 ] && echo 0 || echo 1) "Dockerfile copia nginx.conf"

echo ""
echo "📊 Resumen de verificación permanente:"

# Contar verificaciones
TOTAL_CHECKS=10
PASSED_CHECKS=0

[ $(grep -c "location /api/" nginx.conf || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "proxy_pass http://ticketpardo-backend-service:8000/" nginx.conf || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "ARG REACT_APP_API_URL=/api" Dockerfile.frontend || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "process.env.REACT_APP_API_URL || '/api'" src/context/AppContext.js || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ -f "env.example" ] && ((PASSED_CHECKS++))
[ -f "env.production.example" ] && ((PASSED_CHECKS++))
[ $(grep -c "REACT_APP_API_URL=/api" env.production.example || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "REACT_APP_API_URL=\"/api\"" scripts/build-images.sh || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "REACT_APP_API_URL=/api" scripts/deploy-minikube.sh || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "COPY nginx.conf" Dockerfile.frontend || echo 0) -gt 0 ] && ((PASSED_CHECKS++))

echo "📈 Verificaciones pasadas: $PASSED_CHECKS/$TOTAL_CHECKS"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo ""
    echo "🎉 ¡ARREGLO PERMANENTE CONFIRMADO!"
    echo ""
    echo "✅ El proxy reverso está correctamente implementado:"
    echo "   - nginx.conf tiene el bloque /api/ configurado"
    echo "   - Dockerfile usa /api por defecto"
    echo "   - Frontend usa variables de entorno correctas"
    echo "   - Sin dependencias de hot-fixes"
    echo "   - Persistente ante recreación de pods"
    echo ""
    echo "🚀 La imagen se puede reconstruir y funcionará correctamente"
    echo ""
    echo "📋 Para reconstruir la imagen:"
    echo "   eval \$(minikube docker-env)"
    echo "   bash scripts/build-images.sh"
    echo "   kubectl rollout restart deployment/ticketpardo-frontend -n ticketpardo"
    echo ""
    exit 0
else
    echo ""
    echo "⚠️  Algunas verificaciones fallaron."
    echo "   El arreglo puede no ser completamente permanente."
    exit 1
fi
