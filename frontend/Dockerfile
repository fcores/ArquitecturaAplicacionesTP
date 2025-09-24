# Etapa de build
FROM node:18-alpine as build

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código fuente
COPY . .

# Crear build de producción
RUN npm run build

# Etapa de producción con Nginx
FROM nginx:alpine

# Copiar build al directorio de Nginx
COPY --from=build /app/build /usr/share/nginx/html

# Copiar configuración personalizada de Nginx (opcional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

# Comando por defecto (Nginx se ejecuta automáticamente)
CMD ["nginx", "-g", "daemon off;"]