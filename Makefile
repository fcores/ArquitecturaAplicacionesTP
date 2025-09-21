# Makefile para TicketPardo
# Comandos útiles para el desarrollo y despliegue

.PHONY: help install dev build deploy clean

# Variables
DOCKER_REGISTRY ?= localhost:5000
IMAGE_TAG ?= latest

help: ## Mostrar esta ayuda
	@echo "TicketPardo - Comandos disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Instalar dependencias locales
	npm install
	pip install -r requirements.txt

dev: ## Ejecutar en modo desarrollo
	npm run dev

build: ## Construir imágenes Docker
	@echo "🏗️ Construyendo imágenes Docker..."
	bash scripts/build-images.sh

deploy-local: ## Desplegar con Docker Compose
	@echo "🐳 Desplegando con Docker Compose..."
	docker-compose up -d

deploy-k8s: build ## Desplegar en Minikube
	@echo "☸️ Desplegando en Minikube..."
	bash scripts/deploy-minikube.sh

setup-ec2: ## Configurar EC2 para Minikube
	@echo "🔧 Configurando EC2..."
	bash scripts/setup-ec2.sh

quick-deploy: ## Despliegue rápido en EC2
	@echo "🚀 Despliegue rápido..."
	bash scripts/quick-deploy.sh

monitor: ## Monitorear el estado de la aplicación
	@echo "📊 Monitoreando aplicación..."
	bash scripts/monitor.sh

clean: ## Limpiar recursos
	@echo "🧹 Limpiando recursos..."
	bash scripts/cleanup.sh

logs-backend: ## Ver logs del backend
	kubectl logs -f deployment/ticketpardo-backend -n ticketpardo

logs-frontend: ## Ver logs del frontend
	kubectl logs -f deployment/ticketpardo-frontend -n ticketpardo

scale-backend: ## Escalar backend (uso: make scale-backend REPLICAS=3)
	kubectl scale deployment ticketpardo-backend --replicas=${REPLICAS:-2} -n ticketpardo

scale-frontend: ## Escalar frontend (uso: make scale-frontend REPLICAS=2)
	kubectl scale deployment ticketpardo-frontend --replicas=${REPLICAS:-1} -n ticketpardo

restart-backend: ## Reiniciar backend
	kubectl rollout restart deployment/ticketpardo-backend -n ticketpardo

restart-frontend: ## Reiniciar frontend
	kubectl rollout restart deployment/ticketpardo-frontend -n ticketpardo

port-forward: ## Configurar port-forward para acceso local
	@echo "🔗 Configurando port-forward..."
	@echo "Frontend disponible en: http://localhost:3000"
	@echo "Backend disponible en: http://localhost:8000"
	kubectl port-forward svc/ticketpardo-frontend-service 3000:80 -n ticketpardo &
	kubectl port-forward svc/ticketpardo-backend-service 8000:8000 -n ticketpardo &

status: ## Ver estado de todos los recursos
	@echo "📊 Estado de Kubernetes:"
	kubectl get all -n ticketpardo
	@echo ""
	@echo "🐳 Estado de Docker:"
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

test-api: ## Probar la API
	npm run test-api
