# Fleet Manager API 🚗

Sistema de gestión de flotas de vehículos con API REST y interfaz web. Permite administrar vehículos, servicios de mantenimiento y generar reportes agregados.

## 🛠 Tecnologías

- **Ruby** 3.2.2
- **Rails** 7.1.x
- **PostgreSQL** 14+
- **JWT** para autenticación
- **Pundit** para autorización por roles
- **Discard** para soft delete (eliminación suave)
- **RSpec + FactoryBot** para testing
- **Pagy** para paginación
- **ActiveModelSerializers** para serialización JSON

## 📦 Instalación

### Prerrequisitos

```bash
ruby 3.2.2
postgresql 14+
bundler
```

### Setup

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

### Usuarios de prueba
Después del seed tendrás disponible:
- **Admin**: `admin@example.com` / `password123` (Todos los permisos)
- **Manager**: `manager@example.com` / `password123` (CRUD sin eliminar vehículos)
- **Viewer**: `viewer@example.com` / `password123` (Solo lectura)

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

**Nota**: Puedes usar cualquiera de los usuarios de prueba (admin, manager, viewer) para obtener diferentes niveles de acceso.

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
- `include_discarded` - Incluir vehículos eliminados (solo admin): `true`/`false`
- `only_discarded` - Solo vehículos eliminados (solo admin): `true`/`false`

**Ejemplos:**
```bash
# Vehículos activos (comportamiento por defecto)
GET /api/v1/vehicles?q=toyota&status=active&sort=year&items=10&page=1

# Solo vehículos eliminados (solo admin)
GET /api/v1/vehicles?only_discarded=true

# Todos los vehículos incluyendo eliminados (solo admin)
GET /api/v1/vehicles?include_discarded=true
```

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

#### Ver vehículo
```bash
GET /api/v1/vehicles/:id
```

#### Actualizar vehículo
```bash
PUT /api/v1/vehicles/:id
Content-Type: application/json

{
  "vehicle": {
    "status": "in_maintenance"
  }
}
```

#### Eliminar vehículo (Soft Delete)
```bash
DELETE /api/v1/vehicles/:id
```

#### Restaurar vehículo eliminado
```bash
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
- `sort` - Ordenar por campo (`date`, `status`, `priority`, `cost_cents`)
- `items` - Elementos por página
- `page` - Página actual
- `include_discarded` - Incluir servicios eliminados (solo admin): `true`/`false`
- `only_discarded` - Solo servicios eliminados (solo admin): `true`/`false`

**Ejemplos:**
```bash
# Servicios activos (comportamiento por defecto)
GET /api/v1/vehicles/1/maintenance_services?status=pending&from=2024-01-01&to=2024-12-31

# Solo servicios eliminados (solo admin)
GET /api/v1/vehicles/1/maintenance_services?only_discarded=true

# Todos los servicios incluyendo eliminados (solo admin)
GET /api/v1/vehicles/1/maintenance_services?include_discarded=true
```

#### Crear servicio de mantenimiento
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

#### Ver servicio
```bash
GET /api/v1/maintenance_services/:id
```

#### Actualizar servicio
```bash
PUT /api/v1/maintenance_services/:id
Content-Type: application/json

{
  "maintenance_service": {
    "status": "completed",
    "completed_at": "2024-03-15T10:30:00Z"
  }
}
```

#### Eliminar servicio (Soft Delete)
```bash
DELETE /api/v1/maintenance_services/:id
```

#### Restaurar servicio eliminado
```bash
POST /api/v1/maintenance_services/:id/restore
```

### Reportes

#### Resumen de mantenimientos
```bash
GET /api/v1/reports/maintenance_summary
```

**Parámetros opcionales:**
- `from` - Fecha desde (YYYY-MM-DD)
- `to` - Fecha hasta (YYYY-MM-DD)
- `vehicle_id` - ID específico de vehículo

**Ejemplo:**
```bash
GET /api/v1/reports/maintenance_summary?from=2024-01-01&to=2024-12-31
```

**Respuesta:**
```json
{
  "data": {
    "totals": {
      "orders_count": 150,
      "total_cost_cents": 750000
    },
    "breakdown_by_status": [
      {
        "key": "completed",
        "services_count": 100,
        "total_cost_cents": 500000
      }
    ],
    "breakdown_by_vehicle": [
      {
        "vehicle_id": 1,
        "brand": "Toyota",
        "model": "Corolla",
        "plate": "ABC123",
        "services_count": 5,
        "total_cost_cents": 25000
      }
    ],
    "top_vehicles_by_cost": [
      {
        "vehicle_id": 1,
        "brand": "Toyota",
        "model": "Corolla",
        "plate": "ABC123",
        "services_count": 8,
        "total_cost_cents": 45000
      }
    ]
  }
}
```

## 🌐 Interfaz Web

Disponible en `http://localhost:3000`:

- **Listado de vehículos** - `/`
- **Crear vehículo** - `/vehicles/new`
- **Ver vehículo** - `/vehicles/:id`
- **Editar vehículo** - `/vehicles/:id/edit`
- **Servicios de mantenimiento** - `/vehicles/:id/maintenance_services/new`

## 🔧 Modelos

### Vehicle
```ruby
# Atributos
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
# Atributos
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
# Atributos
email            # String, único (case-insensitive)
password_digest  # String (bcrypt)
role            # String, default: admin
```

## 📋 Reglas de Negocio

1. **VIN y Placa únicos** - Case-insensitive en toda la aplicación
2. **Status automático de vehículos**:
   - `in_maintenance` si tiene servicios `pending` o `in_progress`
   - `active` cuando no tiene servicios pendientes
3. **Servicios completed** - Requieren `completed_at` timestamp
4. **Fechas válidas** - No se permiten fechas futuras en servicios
5. **Costos en centavos** - Para evitar problemas de precisión decimal
6. **Soft Delete** - Los registros eliminados se marcan con `discarded_at` y pueden restaurarse

## 🧪 Testing

```bash
# Ejecutar todas las pruebas
bundle exec rspec

# Ejecutar con cobertura
COVERAGE=true bundle exec rspec

# Ejecutar pruebas específicas
bundle exec rspec spec/models/
bundle exec rspec spec/requests/api/v1/vehicles_spec.rb
```

### Factories disponibles
```ruby
# spec/factories/
create(:vehicle)                    # Vehículo básico
create(:vehicle, :inactive)         # Vehículo inactivo
create(:maintenance_service)        # Servicio básico
create(:maintenance_service, :completed)  # Servicio completado
create(:user)                       # Usuario admin
```

## ⚙️ Configuración

### Credenciales
Las variables sensibles se manejan con Rails credentials:
```bash
# Ver credenciales actuales
rails credentials:show

# Editar credenciales (abre editor)
rails credentials:edit
```

Estructura de credentials:
```yaml
jwt:
  secret: your-jwt-secret-key
```

## 📊 Monitoreo

### Health Check
```bash
GET /health
```

Retorna status de la aplicación y conectividad a BD.

### Logging
Los logs incluyen:
- Requests HTTP con parámetros
- Queries SQL con timing
- Errores de autenticación
- Validaciones fallidas

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
| Restaurar vehículos/servicios | ✅ | ❌ | ❌ |

## 🤝 Desarrollo

### Estructura del proyecto
```
app/
├── controllers/
│   ├── api/v1/          # Controladores API
│   ├── web/             # Controladores web
│   └── concerns/        # Mixins compartidos
├── models/              # Modelos ActiveRecord
├── services/            # Lógica de negocio
│   └── reports/         # Servicios de reportes
├── serializers/         # Serialización JSON
└── views/               # Vistas HTML (ERB)
```

---

**Fleet Manager API v1.0** - Sistema de gestión de flotas vehiculares 🚗✨