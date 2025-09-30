#!/bin/bash

# Script de inicio rápido para Docker
# Uso: ./docker-start.sh

set -e

echo "🐳 Fleet Manager - Inicio con Docker"
echo "===================================="
echo ""

# Verificar que Docker esté instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    echo "   Instala Docker Desktop desde: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Verificar que Docker Compose esté instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose no está instalado"
    exit 1
fi

# Verificar que Docker esté corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker no está corriendo"
    echo "   Inicia Docker Desktop primero"
    exit 1
fi

echo "✅ Docker está instalado y corriendo"
echo ""

# Construir imágenes
echo "📦 Construyendo imágenes Docker..."
docker-compose build

# Iniciar servicios en segundo plano
echo "🚀 Iniciando servicios..."
docker-compose up -d

# Esperar a que la base de datos esté lista
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 5

# Configurar base de datos
echo "🗄️  Configurando base de datos..."
docker-compose exec -T web bundle exec rails db:create db:migrate db:seed

echo ""
echo "✅ ¡Aplicación iniciada correctamente!"
echo ""
echo "🌐 Accede a la aplicación en: http://localhost:3000"
echo "📊 Reportes disponibles en: http://localhost:3000/reports/maintenance_summary"
echo ""
echo "📝 Comandos útiles:"
echo "   make logs          - Ver logs"
echo "   make console       - Abrir consola Rails"
echo "   make shell         - Acceder al contenedor"
echo "   make down          - Detener servicios"
echo "   make help          - Ver todos los comandos"
echo ""