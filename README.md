# TicketPardo - React + FastAPI

Aplicación web moderna para la venta de entradas del último partido de Messi, construida con React (frontend) y FastAPI (backend) con diseño mobile-first.

## 🚀 Características

- **Frontend React**: Interfaz moderna y responsiva
- **Backend FastAPI**: API RESTful con Python
- **Diseño Mobile-First**: Optimizado para dispositivos móviles
- **Generación de QR Codes**: Para validación de entradas
- **Búsqueda en tiempo real**: Filtrado de eventos
- **Modal de compra**: Proceso de compra intuitivo
- **Newsletter**: Suscripción para alertas
- **Animaciones**: Transiciones suaves con Framer Motion

## 🛠️ Tecnologías

### Frontend
- React 18
- Styled Components
- Framer Motion
- React Router DOM
- Axios
- React Icons
- QRCode React
- React Hook Form
- React Hot Toast

### Backend
- FastAPI
- Uvicorn
- Pydantic
- QRCode (Python)
- Pillow
- Python Multipart

## 📦 Instalación

### Requisitos Previos
- Python 3.8+
- Node.js 16+
- npm o yarn

### Instalación Automática (Windows)
1. Ejecuta `install.bat` para instalar todas las dependencias

### Instalación Manual

#### Backend (FastAPI)
```bash
# Instalar dependencias de Python
pip install -r requirements.txt
```

#### Frontend (React)
```bash
# Instalar dependencias de Node.js
npm install
```

## 🚀 Ejecución

### Opción 1: Scripts Automáticos (Windows)
1. Ejecuta `start-backend.bat` para iniciar el servidor FastAPI
2. Ejecuta `start-frontend.bat` para iniciar el servidor React

### Opción 2: Comandos Manuales

#### Backend
```bash
cd backend
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

#### Frontend
```bash
npm start
```

## 🌐 URLs de Acceso

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **Documentación API**: http://localhost:8000/docs

## 📱 Características Mobile-First

### Diseño Responsivo
- Breakpoints optimizados para móviles
- Grid system adaptativo
- Navegación hamburguesa en móviles
- Botones y elementos táctiles optimizados

### Optimizaciones Móviles
- Viewport configurado correctamente
- Touch targets de tamaño adecuado
- Scroll suave entre secciones
- Modal de compra optimizado para móviles

## 🔧 Estructura del Proyecto

```
ticketpardo-react/
├── backend/
│   └── main.py                 # Servidor FastAPI
├── src/
│   ├── components/
│   │   ├── Header.js           # Navegación
│   │   ├── Hero.js             # Sección principal
│   │   ├── Events.js           # Lista de eventos
│   │   ├── Categories.js       # Categorías de entradas
│   │   ├── Newsletter.js       # Suscripción
│   │   ├── Footer.js           # Pie de página
│   │   └── PurchaseModal.js    # Modal de compra
│   ├── context/
│   │   └── AppContext.js       # Estado global
│   ├── styles/
│   │   └── GlobalStyles.js     # Estilos globales
│   ├── App.js                  # Componente principal
│   └── index.js                # Punto de entrada
├── public/
│   └── index.html              # HTML principal
├── package.json                # Dependencias React
├── requirements.txt            # Dependencias Python
└── README.md                   # Documentación
```

## 📋 Endpoints de la API

### Eventos
- `GET /api/events` - Obtener todos los eventos
- `GET /api/events/{id}` - Obtener evento específico
- `GET /api/search?query={term}` - Buscar eventos

### Categorías
- `GET /api/categories` - Obtener categorías de entradas

### Compras
- `POST /api/purchase` - Procesar compra de entradas

### Newsletter
- `POST /api/newsletter` - Suscribir al newsletter

## 🎨 Variables CSS Personalizables

El proyecto utiliza variables CSS para fácil personalización:

```css
:root {
  --primary: #2563eb;           /* Color principal */
  --secondary: #f59e0b;         /* Color secundario */
  --accent: #dc2626;           /* Color de acento */
  --text-primary: #1f2937;     /* Texto principal */
  --text-secondary: #6b7280;   /* Texto secundario */
  --bg-primary: #ffffff;       /* Fondo principal */
  --bg-secondary: #f8f9fa;     /* Fondo secundario */
  --border-radius: 12px;       /* Radio de bordes */
  --shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Sombra */
}
```

## 📱 Breakpoints Responsivos

- **Mobile**: < 768px
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px - 1279px
- **Large Desktop**: ≥ 1280px

## 🔍 Funcionalidades Principales

### Búsqueda de Eventos
- Búsqueda en tiempo real
- Filtrado por título, ubicación y categoría
- Resultados dinámicos

### Proceso de Compra
- Selección de cantidad de entradas
- Validación de formularios
- Generación automática de QR codes
- Confirmación de compra

### Newsletter
- Suscripción por email
- Validación de formularios
- Notificaciones de éxito/error

## 🚀 Despliegue

### Frontend (React)
```bash
npm run build
```

### Backend (FastAPI)
```bash
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

## 📄 Licencia

Este proyecto es para fines educativos y de demostración.

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

---

**TicketPardo** - Entradas oficiales para el último partido de Messi ⚽
