# n8n Debian Docker Deployment

![n8n](https://img.shields.io/badge/n8n-Latest-EA4B71?style=flat-square&logo=n8n)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker)
![Debian](https://img.shields.io/badge/Debian-12-A81D33?style=flat-square&logo=debian)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat-square&logo=postgresql)
![Nginx](https://img.shields.io/badge/Nginx-Alpine-009639?style=flat-square&logo=nginx)
![Cloudflare](https://img.shields.io/badge/Cloudflare-Tunnel-F38020?style=flat-square&logo=cloudflare)

Deployment completo de **n8n** (plataforma de automatización) en servidor Debian con Docker Compose, PostgreSQL, Nginx y túnel Cloudflare para acceso seguro desde internet.


## 🌟 Open Source

Este proyecto es de código abierto para ayudar a la comunidad DevOps a deployar n8n fácilmente.
Todos los scripts y configuraciones están disponibles para que puedas aprender y adaptar.

**Si este proyecto te fue útil, considera dejarle una ⭐ al repo!**

## 🎯 Características

- ✅ **n8n** - Plataforma de automatización self-hosted
- ✅ **PostgreSQL 15** - Base de datos persistente
- ✅ **Nginx** - Reverse proxy y servidor web
- ✅ **Docker Compose** - Gestión de containers
- ✅ **Cloudflare Tunnel** - Acceso seguro sin exponer puertos
- ✅ **SSL/TLS** - Certificados automáticos vía Cloudflare
- ✅ **Health checks** - Monitoreo de servicios

## 📋 Requisitos

- Servidor Debian 12+ (o Ubuntu)
- Docker y Docker Compose instalados
- Cuenta en Cloudflare (gratuita)
- Dominio propio (puede ser gratuito)
- Mínimo 2GB RAM y 10GB disco

## 🚀 Quick Start

### 1. Clonar el repositorio

```bash
git clone https://github.com/romerok9/n8n-debian-docker-deployment.git
cd n8n-debian-docker-deployment
```

### 2. Configurar variables de entorno

```bash
cp config/.env.example config/.env
nano config/.env
```

Edita las siguientes variables:

```env
# PostgreSQL
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=n8n_db

# n8n
N8N_ENCRYPTION_KEY=your_random_encryption_key
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_admin_password

# Dominio
N8N_HOST=n8n.yourdomain.com
GENERIC_TIMEZONE=America/New_York
```

### 3. Configurar Cloudflare Tunnel

```bash
# Instalar cloudflared
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
sudo dpkg -i cloudflared.deb

# Autenticar
cloudflared tunnel login

# Crear túnel
cloudflared tunnel create n8n-tunnel

# Copiar el UUID del túnel y actualizar config/cloudflared-config.yml
```

Ver guía completa: [docs/CLOUDFLARE_SETUP.md](docs/CLOUDFLARE_SETUP.md)

### 4. Desplegar

```bash
# Copiar configuración de Cloudflare
sudo mkdir -p /etc/cloudflared
sudo cp config/cloudflared-config.yml /etc/cloudflared/config.yml

# Iniciar servicios
docker-compose up -d

# Iniciar túnel Cloudflare
sudo cloudflared service install
sudo systemctl start cloudflared
```

### 5. Acceder a n8n

```
https://n8n.yourdomain.com
```

## 📂 Estructura del Proyecto

```
n8n-debian-docker-deployment/
├── docker-compose.yml           # Definición de servicios
├── config/
│   ├── env.example             # Variables de entorno (template)
│   └── cloudflared-config.yml  # Configuración Cloudflare Tunnel
├── docs/
│   └── CLOUDFLARE_SETUP.md     # Guía configuración Cloudflare
├── scripts/
│   ├── backup.sh               # Script backup PostgreSQL
│   └── restore.sh              # Script restauración
├── .gitignore
├── LICENSE
└── README.md
```

## 🐳 Servicios Docker

### n8n
- **Puerto interno**: 5678
- **Imagen**: n8nio/n8n:latest
- **Volumen**: `n8n_data` (persistencia de workflows)
- **Dependencias**: PostgreSQL

### PostgreSQL
- **Puerto interno**: 5432
- **Imagen**: postgres:15
- **Volumen**: `pg_data` (persistencia de base de datos)
- **Health check**: Cada 10s

### Nginx
- **Puertos**: 80, 443
- **Imagen**: nginx:alpine
- **Volumen**: `website/html` (sitio web estático)
- **Función**: Reverse proxy y servidor web

## 🔐 Seguridad

- ✅ **No expone puertos públicos** - Todo a través de Cloudflare Tunnel
- ✅ **SSL/TLS automático** - Certificados gestionados por Cloudflare
- ✅ **Autenticación básica** - Protección de acceso a n8n
- ✅ **Variables de entorno** - Credenciales fuera del código
- ✅ **Network aislada** - Containers en red privada Docker

## 🛠️ Comandos Útiles

### Ver logs

```bash
# Todos los servicios
docker-compose logs -f

# Solo n8n
docker-compose logs -f n8n

# Solo PostgreSQL
docker-compose logs -f postgres
```

### Gestión de servicios

```bash
# Detener
docker-compose stop

# Reiniciar
docker-compose restart

# Eliminar (mantiene volúmenes)
docker-compose down

# Eliminar todo (⚠️ incluye datos)
docker-compose down -v
```

### Backup

```bash
./scripts/backup.sh
```

### Restaurar

```bash
./scripts/restore.sh backup_file.sql
```

## 📊 Monitoreo

Verificar estado de servicios:

```bash
docker-compose ps
```

Verificar salud de PostgreSQL:

```bash
docker exec postgres pg_isready -U your_user
```

Verificar túnel Cloudflare:

```bash
sudo systemctl status cloudflared
```

## 🔄 Actualización

```bash
# Detener servicios
docker-compose down

# Actualizar imágenes
docker-compose pull

# Reiniciar
docker-compose up -d
```

## 🐛 Troubleshooting

### n8n no conecta a PostgreSQL

```bash
# Verificar variables de entorno
docker-compose exec n8n env | grep DB

# Verificar salud de PostgreSQL
docker-compose exec postgres pg_isready
```

### Cloudflare Tunnel no funciona

```bash
# Ver logs
sudo journalctl -u cloudflared -f

# Verificar configuración
sudo cloudflared tunnel info n8n-tunnel
```

## 📚 Documentación Adicional

- [Configuración Cloudflare Tunnel](docs/CLOUDFLARE_SETUP.md) - Guía completa paso a paso
- [n8n Official Docs](https://docs.n8n.io/) - Documentación oficial de n8n
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) - Documentación de Cloudflare
- [Docker Compose Docs](https://docs.docker.com/compose/) - Referencia de Docker Compose

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si encuentras algún problema o tienes sugerencias:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**Kevin Jose Romero Perez**

- GitHub: [@romerok9](https://github.com/romerok9)
- LinkedIn: [kevs-romero](https://www.linkedin.com/in/kevs-romero/)

## ⭐ Show your support

Si este proyecto te fue útil, ¡dale una ⭐️!

---

**Note**: Este deployment está diseñado para entornos de desarrollo/pruebas y pequeñas empresas. Para producción empresarial, considera implementar:
- Alta disponibilidad con múltiples réplicas
- Backup automático programado
- Monitoreo con Prometheus/Grafana
- Load balancer

