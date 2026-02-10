*This project has been created as part of the 42 curriculum by aarustam.*

# Inception

## Description

Inception is a Docker-based infrastructure project that sets up a complete web stack using containerization. The project demonstrates system administration skills by virtualizing multiple services using Docker containers, including NGINX as a reverse proxy with SSL/TLS encryption, WordPress with PHP-FPM, and MariaDB as the database backend.

The goal of this project is to:
- Learn Docker and containerization concepts
- Set up a multi-container application using Docker Compose
- Configure services to work together securely
- Understand Docker volumes, networks, and secrets management
- Implement proper security practices (TLS, secrets management)

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Virtual Machine (VM) environment
- Access to create directories in `/home/aarustam/data`

### Setup

1. **Clone the repository** (if applicable) or navigate to the project directory

2. **Set your 42 login in one place** — edit the top of the `Makefile`:
   ```makefile
   LOGIN = yourlogin
   ```
   Copy `srcs/.env.example` to `srcs/.env` and set `LOGIN` and `DOMAIN_NAME` to your login (e.g. `LOGIN=yourlogin`, `DOMAIN_NAME=yourlogin.42.fr`).

3. **Create secrets** at project root (never commit these):
   ```bash
   echo "your_db_user_password" > secrets/db_password.txt
   echo "your_db_root_password" > secrets/db_root_password.txt
   chmod 600 secrets/*.txt
   ```

4. **Configure domain name** (add to `/etc/hosts`):
   ```bash
   echo "127.0.0.1 aarustam.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Build and start** (one command):
   ```bash
   make
   ```
   This runs setup (create data dirs), build (Docker images), and start (containers). Or step by step:
   ```bash
   make setup    # Create data directories
   make build    # Build Docker images
   make up       # Start containers
   ```

6. **Access the site**:
   - Open your browser and navigate to `https://yourlogin.42.fr`
   - Accept the self-signed certificate warning (for development)
   - Complete WordPress installation through the web interface

### Available Make Commands

- `make` or `make all` — Setup, build, and start (one command to run everything)
- `make setup` — Create data directories at `/home/$(LOGIN)/data`
- `make build` — Build all Docker images
- `make up` — Start all containers (runs setup + build if needed)
- `make down` — Stop and remove containers
- `make stop` / `make start` — Stop or start containers without removing
- `make logs` — View container logs
- `make ps` — Show running containers
- `make clean` — Stop containers and remove images/volumes
- `make fclean` — Full cleanup (containers, images, volumes, **data directory**, system prune)
- `make re` — fclean then build and start again

Change your 42 login in the `Makefile` (`LOGIN = yourlogin`) and in `srcs/.env` (`LOGIN=yourlogin`, `DOMAIN_NAME=yourlogin.42.fr`).

### Stopping the Project

```bash
make down
```

### Full Cleanup

```bash
make fclean
```

## Project Description

### Docker Usage

This project uses Docker to containerize three main services:
- **NGINX**: Web server and reverse proxy; only entrypoint on port 443 with TLSv1.2/TLSv1.3
- **WordPress**: CMS with PHP-FPM only (no nginx inside the container)
- **MariaDB**: Database only (no nginx)

Each service runs in its own container; image names match service names (with a non-latest tag). A custom bridge network connects the containers; named volumes persist data under `/home/<login>/data`.

### Design Choices

1. **Base Images**: Alpine Linux 3.18 (penultimate stable) for small size and security
2. **Container Architecture**: Each service in its own container; image names match service names (nginx, wordpress, mariadb)
3. **Network**: Custom bridge network (`inception_network`); no host network
4. **Volumes**: Named volumes storing data in `/home/<login>/data/wordpress_data` and `mariadb_data` via local driver
5. **Secrets Management**: Docker secrets used for sensitive data (passwords) instead of environment variables
6. **SSL/TLS**: Self-signed certificates generated at runtime for development purposes

### Comparisons

#### Virtual Machines vs Docker

**Virtual Machines:**
- Full OS virtualization with hypervisor
- Higher resource overhead (RAM, disk space)
- Slower startup times
- Complete isolation at hardware level
- Better for running different OS types

**Docker:**
- Containerization using host OS kernel
- Lower resource overhead
- Fast startup times (seconds)
- Process-level isolation
- Better for microservices and application deployment
- More efficient resource utilization

**Why Docker for this project:** Docker provides lightweight, fast, and efficient containerization perfect for deploying multiple services that need to work together, with minimal resource overhead compared to VMs.

#### Secrets vs Environment Variables

**Environment Variables:**
- Stored in `.env` files or passed directly
- Visible in process lists (`ps`, `env`)
- Can be logged accidentally
- Easy to use but less secure
- Suitable for non-sensitive configuration

**Docker Secrets:**
- Stored in encrypted files
- Mounted as read-only files in containers
- Not visible in process lists
- More secure for sensitive data
- Managed by Docker Swarm or Docker Compose

**Why Secrets for this project:** Passwords and database credentials are sensitive information that should not be exposed in environment variables or logs. Docker secrets provide better security by storing credentials in separate files that are mounted securely into containers.

#### Docker Network vs Host Network

**Docker Network (Bridge):**
- Containers communicate through virtual network
- Ports must be explicitly exposed
- Better isolation and security
- Allows multiple containers on same port
- Network policies can be applied

**Host Network:**
- Containers use host's network directly
- No network isolation
- Direct access to host ports
- Less secure
- Can cause port conflicts

**Why Docker Network for this project:** Using a custom bridge network provides proper isolation between containers, allows controlled communication, and follows Docker best practices. Host network mode is forbidden in the requirements and would compromise security.

#### Docker Volumes vs Bind Mounts

**Docker Volumes:**
- Managed by Docker
- Stored in Docker's directory (`/var/lib/docker/volumes/`)
- Portable across different hosts
- Better performance on some systems
- Can be backed up easily

**Bind Mounts:**
- Direct mapping to host filesystem
- Full control over location
- Easier to access from host
- Can cause permission issues
- Less portable

**Why Named Volumes for this project:** The requirements specify using named volumes for data persistence. While we configure them to store data in `/home/aarustam/data` using volume driver options, they remain Docker-managed volumes, providing better portability and Docker integration compared to direct bind mounts.

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/support/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Alpine Linux Documentation](https://wiki.alpinelinux.org/)

### Tutorials and Articles
- Docker best practices: [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- Container security: [Docker Security](https://docs.docker.com/engine/security/)
- Docker volumes: [Manage data in Docker](https://docs.docker.com/storage/)

### AI Usage

AI tools were used in this project for:

- **Troubleshooting**: Debugging Docker build errors and container connectivity issues
- **Documentation**: Structuring README and technical documentation


All AI-generated content was reviewed, tested, and understood before implementation. The project structure, security configurations, and design decisions were validated through manual testing and peer review.
