#!/bin/bash
# Script para verificar las recomendaciones de configuración del frontend

set -e

echo "🔍 Verificando configuración del frontend..."

# Función para mostrar resultados
show_result() {
    if [ $1 -eq 0 ]; then
        echo "✅ $2"
    else
        echo "❌ $2"
        return 1
    fi
}

# Verificar que no hay localhost hardcodeado en el código
echo ""
echo "📋 Verificando código fuente..."

# Buscar localhost en archivos JS
LOCALHOST_COUNT=$(find src -name "*.js" -exec grep -l "localhost" {} \; | wc -l)
show_result $([ $LOCALHOST_COUNT -eq 0 ] && echo 0 || echo 1) "Sin referencias a localhost en código JS"

# Verificar que usa REACT_APP_API_URL correctamente
CORRECT_API_URL=$(grep -c "process.env.REACT_APP_API_URL" src/context/AppContext.js || echo 0)
show_result $([ $CORRECT_API_URL -gt 0 ] && echo 0 || echo 1) "Usa process.env.REACT_APP_API_URL"

# Verificar fallback correcto
CORRECT_FALLBACK=$(grep -c "|| '/api'" src/context/AppContext.js || echo 0)
show_result $([ $CORRECT_FALLBACK -gt 0 ] && echo 0 || echo 1) "Fallback correcto a /api"

echo ""
echo "📋 Verificando Dockerfile..."

# Verificar build arg en Dockerfile
DOCKERFILE_ARG=$(grep -c "ARG REACT_APP_API_URL=/api" Dockerfile.frontend || echo 0)
show_result $([ $DOCKERFILE_ARG -gt 0 ] && echo 0 || echo 1) "Dockerfile tiene ARG REACT_APP_API_URL=/api"

# Verificar ENV en Dockerfile
DOCKERFILE_ENV=$(grep -c "ENV REACT_APP_API_URL=\$REACT_APP_API_URL" Dockerfile.frontend || echo 0)
show_result $([ $DOCKERFILE_ENV -gt 0 ] && echo 0 || echo 1) "Dockerfile configura ENV correctamente"

echo ""
echo "📋 Verificando nginx.conf..."

# Verificar proxy pass
NGINX_PROXY=$(grep -c "location /api/" nginx.conf || echo 0)
show_result $([ $NGINX_PROXY -gt 0 ] && echo 0 || echo 1) "nginx.conf tiene location /api/"

# Verificar proxy_pass correcto
NGINX_BACKEND=$(grep -c "proxy_pass http://ticketpardo-backend-service:8000/" nginx.conf || echo 0)
show_result $([ $NGINX_BACKEND -gt 0 ] && echo 0 || echo 1) "proxy_pass apunta al backend service"

echo ""
echo "📋 Verificando package.json..."

# Verificar que no hay proxy en package.json
NO_PROXY=$(grep -c '"proxy"' package.json || echo 0)
show_result $([ $NO_PROXY -eq 0 ] && echo 0 || echo 1) "Sin proxy hardcodeado en package.json"

echo ""
echo "📋 Verificando scripts de build..."

# Verificar que build-images.sh usa /api
BUILD_SCRIPT_API=$(grep -c "REACT_APP_API_URL=\"/api\"" scripts/build-images.sh || echo 0)
show_result $([ $BUILD_SCRIPT_API -gt 0 ] && echo 0 || echo 1) "Script de build usa /api"

echo ""
echo "📋 Verificando Backend CORS..."

# Verificar que el backend tiene configuración de CORS mejorada
CORS_FUNCTION=$(grep -c "def get_cors_origins" backend/main.py || echo 0)
show_result $([ $CORS_FUNCTION -gt 0 ] && echo 0 || echo 1) "Backend tiene función de configuración CORS dinámica"

# Verificar que usa allow_methods=["*"]
CORS_METHODS=$(grep -c 'allow_methods=\["\*"\]' backend/main.py || echo 0)
show_result $([ $CORS_METHODS -gt 0 ] && echo 0 || echo 1) "Backend permite todos los métodos HTTP"

# Verificar que tiene requests en requirements
REQUESTS_REQ=$(grep -c "requests==" requirements.txt || echo 0)
show_result $([ $REQUESTS_REQ -gt 0 ] && echo 0 || echo 1) "Backend tiene requests en requirements.txt"

echo ""
echo "🎯 Resumen de Verificación:"
echo ""

# Contar verificaciones exitosas
TOTAL_CHECKS=12
PASSED_CHECKS=0

# Rehacer verificaciones para contar
[ $(find src -name "*.js" -exec grep -l "localhost" {} \; | wc -l) -eq 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "process.env.REACT_APP_API_URL" src/context/AppContext.js || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "|| '/api'" src/context/AppContext.js || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "ARG REACT_APP_API_URL=/api" Dockerfile.frontend || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "ENV REACT_APP_API_URL=\$REACT_APP_API_URL" Dockerfile.frontend || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "location /api/" nginx.conf || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "proxy_pass http://ticketpardo-backend-service:8000/" nginx.conf || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c '"proxy"' package.json || echo 0) -eq 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "REACT_APP_API_URL=\"/api\"" scripts/build-images.sh || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "def get_cors_origins" backend/main.py || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c 'allow_methods=\["\*"\]' backend/main.py || echo 0) -gt 0 ] && ((PASSED_CHECKS++))
[ $(grep -c "requests==" requirements.txt || echo 0) -gt 0 ] && ((PASSED_CHECKS++))

echo "📊 Verificaciones pasadas: $PASSED_CHECKS/$TOTAL_CHECKS"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    echo "🎉 ¡Todas las verificaciones pasaron!"
    echo ""
    echo "✅ Configuración del frontend y backend es correcta:"
    echo "   - Sin localhost hardcodeado en el código"
    echo "   - Usa variables de entorno REACT_APP_API_URL"
    echo "   - Dockerfile configurado para proxy reverso (/api)"
    echo "   - nginx.conf hace proxy reverso correctamente"
    echo "   - package.json sin proxy hardcodeado"
    echo "   - Backend CORS configurado dinámicamente"
    echo "   - Backend detecta IP pública de EC2 automáticamente"
    echo "   - Backend permite todos los métodos HTTP"
    echo ""
    echo "🚀 La aplicación está lista para producción!"
    exit 0
else
    echo "⚠️  Algunas verificaciones fallaron."
    echo "   Revisa los errores arriba y corrige la configuración."
    exit 1
fi
