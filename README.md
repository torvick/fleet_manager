# Fleet Manager API 🚗

Sistema de gestión de flotas de vehículos con API REST y interfaz web. Permite administrar vehículos, servicios de mantenimiento y generar reportes agregados con exportación a CSV/Excel.

## 🛠 Tecnologías

- **Ruby** 3.2.2
- **Rails** 7.1.x
- **PostgreSQL** 15
- **Docker** & Docker Compose
- **JWT** para autenticación
- **Pundit** para autorización por roles
- **Discard** para soft delete
- **RSpec + FactoryBot** para testing
- **Pagy** para paginación
- **ActiveModelSerializers** para serialización JSON
- **Caxlsx** para exportación Excel

## 📦 Instalación y Configuración

### Opción 1: Docker (Recomendado) 🐳

**La forma más rápida de empezar. Solo necesitas Docker Desktop instalado.**

#### Inicio Rápido

```bash
# 1. Clonar repositorio
git clone <repository-url>
cd fleet_manager

# 2. Iniciar con un solo comando
make start
```

¡Listo! La aplicación estará en `http://localhost:3000`

#### Comandos Make Disponibles

```bash
make help          # Ver todos los comandos (21 disponibles)
make start         # Configuración inicial completa
make up            # Iniciar servicios
make up-d          # Iniciar en segundo plano
make down          # Detener servicios
make restart       # Reiniciar servicios
make logs          # Ver logs de todos los servicios
make logs-web      # Ver logs del servicio web
make logs-db       # Ver logs de PostgreSQL
make shell         # Bash en el contenedor
make console       # Consola Rails interactiva
make test          # Ejecutar todos los tests
make db-create     # Crear base de datos
make db-migrate    # Ejecutar migraciones
make db-seed       # Cargar datos de prueba
make db-reset      # Resetear DB completamente
make clean         # Eliminar contenedores y volúmenes
make stop          # Detener aplicación
```

#### Comandos Docker Compose Manuales

Si prefieres no usar Make:

```bash
# Construir imágenes
docker-compose build

# Iniciar servicios en segundo plano
docker-compose up -d

# Configurar base de datos (primera vez)
docker-compose exec web bundle exec rails db:create
docker-compose exec web bundle exec rails db:migrate
docker-compose exec web bundle exec rails db:seed

# Ver logs
docker-compose logs -f

# Ejecutar comandos
docker-compose exec web bundle exec rails console
docker-compose exec web bundle exec rspec
docker-compose exec web bash

# Detener servicios
docker-compose down

# Detener y eliminar todo (incluyendo datos)
docker-compose down -v
```

#### Servicios Docker

**PostgreSQL 15:**
- Puerto: `5433` (puerto externo para evitar conflictos con PostgreSQL local en 5432)
- Usuario: `postgres`
- Password: `postgres`
- Base de datos: `fleet_manager_development`
- Volumen persistente: `postgres_data`
- **Nota**: Los contenedores internamente usan el puerto 5432

**Rails (Web):**
- Puerto: `3000`
- Hot reload activado
- Bundle cache persistente
- Entrypoint automático para DB

#### Variables de Entorno

Configuradas en `docker-compose.yml`:

```yaml
RAILS_ENV: development
DATABASE_HOST: db
DATABASE_USERNAME: postgres
DATABASE_PASSWORD: postgres
DATABASE_NAME: fleet_manager_development
JWT_SECRET: development-jwt-secret-key-change-in-production
```
---

### Opción 2: Instalación Local

#### Prerrequisitos

- Ruby 3.2.2
- PostgreSQL 14+
- Bundler

#### Setup Local

```bash
# 1. Clonar repositorio
git clone <repository-url>
cd fleet_manager

# 2. Instalar dependencias
bundle install

# 3. Configurar base de datos
rails db:create
rails db:migrate

# 4. Generar datos de prueba
rails db:seed

# 5. Iniciar servidor
rails server
```

El servidor estará disponible en `http://localhost:3000`

---

## 👥 Usuarios de Prueba

Después del seed tendrás disponibles:

- **Admin**: `admin@example.com` / `password123` (Todos los permisos)
- **Manager**: `manager@example.com` / `password123` (CRUD sin eliminar vehículos)
- **Viewer**: `viewer@example.com` / `password123` (Solo lectura)

## 🌐 Acceso a la Aplicación

**Interfaz Web:**
- 🏠 Inicio: http://localhost:3000
- 📊 Reportes: http://localhost:3000/reports/maintenance_summary

**API REST:**
- 🔗 Base URL: http://localhost:3000/api/v1
- 🏥 Health Check: http://localhost:3000/health

## 🔑 Autenticación

### Obtener Token JWT

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "token_type": "Bearer",
  "expires_in": 86400,
  "user": {
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

### Usar el Token

Incluir en todas las requests a la API:
```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

## 📚 Endpoints API

### Vehículos

#### Listar vehículos
```bash
GET /api/v1/vehicles
```

**Parámetros opcionales:**
- `q` - Búsqueda por VIN, placa, marca o modelo
- `status` - Filtrar por estado (`active`, `inactive`, `in_maintenance`)
- `brand` - Filtrar por marca
- `year` - Filtrar por año
- `sort` - Ordenar por campo (`brand`, `model`, `year`, `created_at`)
- `items` - Elementos por página (default: 20)
- `page` - Página actual
- `include_discarded` - Incluir vehículos eliminados (solo admin)
- `only_discarded` - Solo vehículos eliminados (solo admin)

#### Crear vehículo
```bash
POST /api/v1/vehicles
Content-Type: application/json

{
  "vehicle": {
    "vin": "1HGCM82633A004352",
    "plate": "ABC123",
    "brand": "Toyota",
    "model": "Corolla",
    "year": 2020,
    "status": "active"
  }
}
```

#### Ver, actualizar y eliminar
```bash
GET /api/v1/vehicles/:id
PUT /api/v1/vehicles/:id
DELETE /api/v1/vehicles/:id
POST /api/v1/vehicles/:id/restore
```

### Servicios de Mantenimiento

#### Listar servicios de un vehículo
```bash
GET /api/v1/vehicles/:vehicle_id/maintenance_services
```

**Parámetros opcionales:**
- `status` - Filtrar por estado (`pending`, `in_progress`, `completed`)
- `priority` - Filtrar por prioridad (`low`, `medium`, `high`)
- `from` - Fecha desde (YYYY-MM-DD)
- `to` - Fecha hasta (YYYY-MM-DD)

#### Crear servicio
```bash
POST /api/v1/vehicles/:vehicle_id/maintenance_services
Content-Type: application/json

{
  "maintenance_service": {
    "description": "Cambio de aceite y filtros",
    "date": "2024-03-15",
    "cost_cents": 25000,
    "priority": "medium",
    "status": "pending"
  }
}
```

### Reportes

#### Resumen de mantenimientos (JSON)
```bash
GET /api/v1/reports/maintenance_summary?from=2024-01-01&to=2024-12-31
```

#### Exportar a CSV
```bash
GET /api/v1/reports/maintenance_summary?export_format=csv&from=2024-01-01&to=2024-12-31
```

#### Exportar a Excel
```bash
GET /api/v1/reports/maintenance_summary?export_format=xlsx&from=2024-01-01&to=2024-12-31
```

**Parámetros:**
- `export_format` - Formato: `csv`, `xlsx` (opcional, default: JSON)
- `from` - Fecha desde (opcional)
- `to` - Fecha hasta (opcional)
- `vehicle_id` - Filtrar por vehículo específico (opcional)

## 📊 Reportes Web

### Vista de Reportes

Accede a: http://localhost:3000/reports/maintenance_summary

**Características:**
- 📅 Filtros por rango de fechas
- 🚗 Filtro por vehículo específico
- 📈 Visualización de:
  - Totales de órdenes y costos
  - Resumen por estado
  - Resumen por vehículo
  - Top 3 vehículos con mayor costo
- 💾 Botones de descarga directa (CSV/Excel)
- 🎨 Interfaz responsive con Bootstrap 5

## 👨‍💻 Documentación de la API

📘 **[Ver Documentación Completa en Postman](https://documenter.getpostman.com/view/2857348/2sB3QFPrYT)**

La documentación incluye:
- Todos los endpoints disponibles
- Ejemplos de request/response
- Códigos de estado HTTP
- Parámetros y autenticación
- Ejemplos ejecutables en Postman

---

## 🔧 Modelos de Datos

### Vehicle
```ruby
vin          # String, único (case-insensitive)
plate        # String, único (case-insensitive)
brand        # String, requerido
model        # String, requerido
year         # Integer, rango 1990..2050
status       # Enum: active, inactive, in_maintenance
discarded_at # DateTime, para soft delete

# Relaciones
has_many :maintenance_services
```

### MaintenanceService
```ruby
vehicle_id     # Foreign Key
description    # String, requerido
status         # Enum: pending, in_progress, completed
date           # Date, no puede ser futura
cost_cents     # Integer, >= 0
priority       # Enum: low, medium, high
completed_at   # DateTime, requerido si status = completed
discarded_at   # DateTime, para soft delete

# Relaciones
belongs_to :vehicle
```

### User
```ruby
email            # String, único (case-insensitive)
password_digest  # String (bcrypt)
role            # String: admin, manager, viewer
```

## 📋 Reglas de Negocio

1. **VIN y Placa únicos** - Case-insensitive
2. **Status automático de vehículos**:
   - `in_maintenance` si tiene servicios `pending` o `in_progress`
   - `active` cuando no tiene servicios pendientes
3. **Servicios completed** - Requieren `completed_at` timestamp
4. **Fechas válidas** - No se permiten fechas futuras
5. **Costos en centavos** - Para precisión decimal
6. **Soft Delete** - Registros eliminados se marcan con `discarded_at`

## 🧪 Testing

```bash
# Docker
make test

# Local
bundle exec rspec

# Con cobertura
COVERAGE=true bundle exec rspec

# Tests específicos
bundle exec rspec spec/models/
bundle exec rspec spec/requests/api/v1/vehicles_spec.rb
```

**Factories disponibles:**
```ruby
create(:vehicle)
create(:vehicle, :inactive)
create(:maintenance_service)
create(:maintenance_service, :completed)
create(:user)
```

## ⚙️ Configuración

### Credenciales Rails
```bash
# Ver credenciales
rails credentials:show

# Editar credenciales
rails credentials:edit
```

**Estructura:**
```yaml
jwt:
  secret: your-jwt-secret-key
```

## 🔒 Seguridad

### Autenticación y Autorización
- **JWT Tokens** - Expiración de 24 horas
- **Roles de usuario** - Admin, Manager, Viewer con Pundit
- **Autorización granular** - Permisos por acción y recurso

### Matriz de Permisos

| Acción | Admin | Manager | Viewer |
|--------|-------|---------|--------|
| Ver vehículos/servicios | ✅ | ✅ | ✅ |
| Crear vehículos/servicios | ✅ | ✅ | ❌ |
| Editar vehículos/servicios | ✅ | ✅ | ❌ |
| Eliminar vehículos | ✅ | ❌ | ❌ |
| Eliminar servicios | ✅ | ❌ | ❌ |
| Restaurar eliminados | ✅ | ❌ | ❌ |

## 🤝 Estructura del Proyecto

```
app/
├── controllers/
│   ├── api/v1/          # Controladores API
│   ├── web/             # Controladores web
│   └── concerns/        # Mixins compartidos
├── models/              # Modelos ActiveRecord
├── services/            # Lógica de negocio
│   ├── reports/         # Servicios de reportes
│   └── exporters/       # Exportadores CSV/Excel
├── serializers/         # Serialización JSON
└── views/               # Vistas HTML (ERB)
```

---

**Fleet Manager API v1.0** - Sistema de gestión de flotas vehiculares 🚗✨

**Desarrollado usando Ruby on Rails y Docker**