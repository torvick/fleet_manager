.PHONY: help build up down restart logs shell console test db-create db-migrate db-seed db-reset clean

help: ## Muestra este mensaje de ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Construye las imágenes Docker
	docker-compose build

up: ## Inicia los servicios
	docker-compose up

up-d: ## Inicia los servicios en segundo plano
	docker-compose up -d

down: ## Detiene y elimina los contenedores
	docker-compose down

restart: ## Reinicia los servicios
	docker-compose restart

logs: ## Muestra los logs de todos los servicios
	docker-compose logs -f

logs-web: ## Muestra los logs del servicio web
	docker-compose logs -f web

logs-db: ## Muestra los logs del servicio db
	docker-compose logs -f db

shell: ## Abre una terminal bash en el contenedor web
	docker-compose exec web bash

console: ## Abre la consola Rails
	docker-compose exec web bundle exec rails console

test: ## Ejecuta los tests
	docker-compose exec web bundle exec rspec

db-create: ## Crea la base de datos
	docker-compose exec web bundle exec rails db:create

db-migrate: ## Ejecuta las migraciones
	docker-compose exec web bundle exec rails db:migrate

db-seed: ## Carga los seeds
	docker-compose exec web bundle exec rails db:seed

db-reset: ## Resetea la base de datos (drop, create, migrate, seed)
	docker-compose exec web bundle exec rails db:drop db:create db:migrate db:seed

db-setup: ## Configura la base de datos por primera vez
	docker-compose exec web bundle exec rails db:create db:migrate db:seed

clean: ## Elimina contenedores, volúmenes e imágenes
	docker-compose down -v
	docker system prune -f

start: build up-d db-setup ## Configuración completa inicial (build, up, db setup)
	@echo "✅ Aplicación iniciada en http://localhost:3000"

stop: down ## Detiene la aplicación