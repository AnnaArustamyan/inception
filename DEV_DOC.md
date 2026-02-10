# Developer Documentation

## Environment Setup

### Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 1.29 or higher (or Docker Compose V2)
- **Virtual Machine**: Ubuntu/Debian-based VM recommended
- **Git**: For version control
- **Text Editor**: VS Code, Vim, or any preferred editor

### Installing Prerequisites

**On Ubuntu/Debian:**
```bash
# Update package list
sudo apt update

# Install Docker
sudo apt install docker.io docker-compose

# Add user to docker group (to run without sudo)
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker-compose --version
```

**On macOS:**
```bash
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Or use Homebrew
brew install --cask docker
```

## Project Structure

```
inception/
├── Makefile                 # Build and management commands
├── README.md               # Project overview
├── USER_DOC.md             # User documentation
├── DEV_DOC.md              # This file
├── .gitignore              # Git ignore rules
├── secrets/                # Docker secrets (not in git)
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/                   # Source files
    ├── docker-compose.yml  # Docker Compose configuration
    ├── .env                # Environment variables
    ├── setup-volumes.sh    # Volume setup script
    └── requirements/       # Service configurations
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   ├── nginx.conf
        │   │   └── default.conf
        │   └── tools/
        │       └── entrypoint.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   └── tools/
        │       ├── install-wordpress.sh
        │       └── www.conf
        └── mariadb/
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/
            │   └── my.cnf
            └── tools/
                └── init-db.sh
```

## Configuration Files

### Environment Variables (.env)

Located in `srcs/.env` (copy from `srcs/.env.example`). Key variables:
- `LOGIN`: Your 42 login — used for volume paths in docker-compose (`/home/${LOGIN}/data/...`)
- `DOMAIN_NAME`: Domain for the website (e.g. `yourlogin.42.fr`)
- `MYSQL_USER`, `MYSQL_DATABASE`, `MYSQL_HOST`: Database config
- `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`: WordPress admin (username cannot contain "admin"/"administrator")

**Important**: Never commit `.env` with real credentials. Set `LOGIN` in both the Makefile and `.env` so paths stay in sync.

### Docker Secrets

Secrets are stored at the **project root** in `secrets/` (not inside `srcs/`):
- `secrets/db_password.txt`: Database user password
- `secrets/db_root_password.txt`: MariaDB root password

**Security**: These files are in `.gitignore` and must never be committed.

### Creating Secrets

```bash
# From project root (inception/)
mkdir -p secrets
echo "your_secure_password_here" > secrets/db_password.txt
echo "your_secure_root_password_here" > secrets/db_root_password.txt
chmod 600 secrets/*.txt

# Copy env template and set your domain
cp srcs/.env.example srcs/.env
# Edit srcs/.env: set DOMAIN_NAME=yourlogin.42.fr
```

## Building and Launching

### Initial Setup

1. **Clone or navigate to project**:
   ```bash
   cd /path/to/inception
   ```

2. **Set your login**: Edit `Makefile` (`LOGIN = yourlogin`) and `srcs/.env` (`LOGIN=yourlogin`, `DOMAIN_NAME=yourlogin.42.fr`).

3. **Create data directories** (or run `make setup`; uses `DATA_PATH=/home/$(LOGIN)/data` from Makefile):
   ```bash
   make setup
   # or manually: mkdir -p /home/yourlogin/data/wordpress_data /home/yourlogin/data/mariadb_data
   ```

4. **Configure domain** (add to `/etc/hosts`):
   ```bash
   echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Create secrets** at project root (see "Creating Secrets" above). Docker Compose references `../secrets/`.

### Building the Project

**Using Makefile (recommended):**
```bash
make              # Setup, build, and start everything
make setup        # Create Docker volumes
make build        # Build Docker images only
```

**Using Docker Compose directly:**
```bash
cd srcs
docker-compose build
```

### Starting the Project

```bash
make up
# or
cd srcs && docker-compose up -d
```

The `-d` flag runs containers in detached mode (background).

### Stopping the Project

```bash
make down
# or
cd srcs && docker-compose down
```

## Managing Containers and Volumes

### Container Management

**List running containers:**
```bash
make ps
# or
cd srcs && docker-compose ps
```

**View logs:**
```bash
make logs                    # All services
cd srcs && docker-compose logs -f nginx      # Specific service
cd srcs && docker-compose logs -f wordpress  # WordPress logs
cd srcs && docker-compose logs -f mariadb    # MariaDB logs
```

**Execute commands in containers:**
```bash
# Access NGINX container
docker exec -it nginx sh

# Access WordPress container
docker exec -it wordpress sh

# Access MariaDB container
docker exec -it mariadb sh

# Run MySQL commands
docker exec -it mariadb mysql -u root -p
```

**Restart a specific service:**
```bash
cd srcs
docker-compose restart nginx
docker-compose restart wordpress
docker-compose restart mariadb
```

**Rebuild and restart a service:**
```bash
cd srcs
docker-compose up -d --build nginx
```

### Volume Management

**List volumes:**
```bash
docker volume ls
```

**Inspect a volume:**
```bash
docker volume inspect wordpress_data
docker volume inspect mariadb_data
```

**View volume data location:**
```bash
docker volume inspect wordpress_data | grep Mountpoint
```

**Backup a volume:**
```bash
# Backup WordPress data
docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_backup.tar.gz -C /data .

# Backup MariaDB data
docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine tar czf /backup/mariadb_backup.tar.gz -C /data .
```

**Restore a volume:**
```bash
# Restore WordPress data
docker run --rm -v wordpress_data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/wordpress_backup.tar.gz"

# Restore MariaDB data
docker run --rm -v mariadb_data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/mariadb_backup.tar.gz"
```

**Remove volumes:**
```bash
make clean  # Removes volumes along with containers
# or manually
docker volume rm wordpress_data mariadb_data
```

## Data Persistence

### Where Data is Stored

**WordPress files**: `/home/aarustam/data/wordpress_data`
- WordPress core, themes, plugins, uploads

**MariaDB data**: `/home/aarustam/data/mariadb_data`
- Database files, tables, user data

### How Data Persists

1. **Named Volumes**: Docker creates named volumes (`wordpress_data`, `mariadb_data`)
2. **Volume driver**: Named volumes use the local driver with `device` set to `/home/aarustam/data/wordpress_data` and `mariadb_data`
3. **Persistence**: Data survives container restarts, rebuilds, and even container removal (as long as volumes exist)

### Backup Strategy

**Regular backups:**
```bash
# Create backup directory
mkdir -p backups

# Backup WordPress
tar czf backups/wordpress_$(date +%Y%m%d).tar.gz -C /home/aarustam/data wordpress_data

# Backup MariaDB
tar czf backups/mariadb_$(date +%Y%m%d).tar.gz -C /home/aarustam/data mariadb_data
```

**Database dump:**
```bash
docker exec mariadb mysqldump -u root -p wordpress > backups/wordpress_db_$(date +%Y%m%d).sql
```

## Development Workflow

### Making Changes

1. **Modify configuration files**:
   - Edit files in `srcs/requirements/[service]/`
   - Update `docker-compose.yml` if needed
   - Modify `.env` for environment variables

2. **Rebuild affected service**:
   ```bash
   cd srcs
   docker-compose up -d --build [service_name]
   ```

3. **Test changes**:
   ```bash
   make logs
   # Check browser
   # Test functionality
   ```

### Debugging

**Check container status:**
```bash
docker ps -a
```

**View detailed logs:**
```bash
cd srcs
docker-compose logs --tail=100 -f
```

**Access container shell:**
```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

**Check network connectivity:**
```bash
# From WordPress container
docker exec wordpress ping mariadb

# From NGINX container
docker exec nginx ping wordpress
```

**Test database connection:**
```bash
docker exec -it mariadb mysql -u wpuser -p wordpress
```

### Common Issues and Solutions

**Port already in use:**
```bash
# Find process using port 443
sudo lsof -i :443
# Kill process or change port in docker-compose.yml
```

**Permission denied errors:**
```bash
# Fix data directory permissions
sudo chown -R $USER:$USER /home/aarustam/data
```

**Container won't start:**
```bash
# Check logs
make logs
# Rebuild from scratch
make fclean
make
```

**Database connection refused:**
```bash
# Check if MariaDB is running
docker ps | grep mariadb
# Check MariaDB logs
cd srcs && docker-compose logs mariadb
# Verify secrets are mounted
docker exec mariadb ls -la /run/secrets/
```

## Testing

### Manual Testing Checklist

- [ ] All containers start successfully
- [ ] Website loads at `https://aarustam.42.fr`
- [ ] SSL certificate is valid (self-signed warning is expected)
- [ ] WordPress installation page appears
- [ ] Can complete WordPress installation
- [ ] Can log in to WordPress admin
- [ ] Can create/edit posts
- [ ] Data persists after container restart
- [ ] Containers restart automatically on crash

### Automated Testing

Create test scripts to verify:
- Container health
- Service connectivity
- SSL certificate validity
- Database accessibility

## Security Considerations

1. **Secrets**: Never commit secrets to git
2. **SSL**: Use proper certificates in production (not self-signed)
3. **Firewall**: Configure firewall rules appropriately
4. **Updates**: Keep base images updated
5. **Permissions**: Use least privilege principle
6. **Network**: Isolate containers with custom network

## Production Deployment

For production deployment:

1. **Use proper SSL certificates** (Let's Encrypt, etc.)
2. **Change all default passwords**
3. **Use environment-specific secrets**
4. **Configure proper backup strategy**
5. **Set up monitoring and logging**
6. **Use Docker Swarm or Kubernetes for orchestration**
7. **Implement proper firewall rules**
8. **Regular security updates**
