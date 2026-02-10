# User Documentation

## Understanding the Services

This infrastructure provides a complete WordPress website stack with the following services:

1. **NGINX** - Web server and reverse proxy that handles incoming HTTPS requests (port 443)
2. **WordPress** - Content management system for creating and managing website content
3. **MariaDB** - Database server that stores all WordPress data (posts, pages, users, settings)

All services run in isolated Docker containers and communicate through a private network.

## Starting the Project

1. **Ensure prerequisites are met**:
   - Docker and Docker Compose are installed
   - You have sudo/root access to create directories

2. **Set your 42 login**: In the project root, edit `Makefile` and set `LOGIN = yourlogin`. Copy `srcs/.env.example` to `srcs/.env` and set `LOGIN=yourlogin`, `DOMAIN_NAME=yourlogin.42.fr`.

3. **Create data directories** (or run `make setup`):
   ```bash
   make setup
   ```

4. **Create secrets** at project root (`secrets/`):
   ```bash
   echo "your_db_password" > secrets/db_password.txt
   echo "your_root_password" > secrets/db_root_password.txt
   ```

5. **Add domain to hosts file**:
   ```bash
   echo "127.0.0.1 yourlogin.42.fr" | sudo tee -a /etc/hosts
   ```

6. **Start the project** (one command: setup + build + start):
   ```bash
   cd /path/to/inception
   make
   ```

   This will create data dirs, build images, and start containers.

7. **Wait for services to be ready** (about 30-60 seconds):
   ```bash
   make logs
   ```
   Look for messages indicating services are running.

## Stopping the Project

To stop all containers:
```bash
make down
```

To stop and remove everything (containers, images, volumes):
```bash
make clean
```

## Accessing the Website

1. **Open your web browser**

2. **Navigate to**: `https://aarustam.42.fr`

3. **Accept the SSL certificate warning**:
   - Since we're using a self-signed certificate for development, your browser will show a security warning
   - Click "Advanced" or "Show Details"
   - Click "Proceed to aarustam.42.fr" or "Accept the Risk"

4. **Complete WordPress installation**:
   - Select your language
   - Fill in site information:
     - Site Title: Your choice
     - Username: Choose a username (cannot contain "admin" or "administrator")
     - Password: Choose a strong password
     - Email: Your email address
   - Click "Install WordPress"

5. **Log in to WordPress**:
   - Use the credentials you just created
   - You'll be taken to the WordPress dashboard

## Accessing the Administration Panel

1. Navigate to `https://aarustam.42.fr/wp-admin`
2. Log in with your WordPress credentials
3. You'll have full access to:
   - Posts and Pages management
   - Media library
   - Users and roles
   - Themes and plugins
   - Settings and configuration

## Locating and Managing Credentials

### Database Credentials

Database credentials are stored using Docker secrets at the **project root**:
- `secrets/db_password.txt` — database user password
- `secrets/db_root_password.txt` — MariaDB root password  
These files are in `.gitignore` and must not be committed. Database user name is set in `srcs/.env` (`MYSQL_USER`).

### WordPress Admin Credentials

WordPress admin credentials are set during the initial installation through the web interface. These are stored in the MariaDB database.

**Important**: The administrator username cannot contain "admin" or "administrator" (project requirement).

### Changing Credentials

1. **Database passwords**: Edit the files in `secrets/` directory, then restart containers:
   ```bash
   make down
   make up
   ```

2. **WordPress admin password**: Log in to WordPress admin panel → Users → Your Profile → Change password

## Checking Service Status

### View Running Containers

```bash
make ps
```

You should see three containers running:
- `nginx`
- `wordpress`
- `mariadb`

### View Container Logs

```bash
make logs
```

To view logs for a specific service:
```bash
cd srcs
docker-compose logs -f nginx    # NGINX logs
docker-compose logs -f wordpress # WordPress logs
docker-compose logs -f mariadb  # MariaDB logs
```

### Check Container Health

```bash
cd srcs
docker-compose ps
```

All containers should show "Up" status.

### Verify Services are Responding

1. **NGINX**: Open `https://aarustam.42.fr` in browser
2. **WordPress**: Should see WordPress installation or login page
3. **Database**: WordPress should be able to connect (check WordPress logs)

### Troubleshooting

**Website not loading:**
- Check if containers are running: `make ps`
- Check logs: `make logs`
- Verify domain is in `/etc/hosts`: `cat /etc/hosts | grep aarustam`
- Check if port 443 is available: `sudo netstat -tulpn | grep 443`

**Database connection errors:**
- Ensure MariaDB container is running: `docker ps | grep mariadb`
- Check MariaDB logs: `cd srcs && docker-compose logs mariadb`
- Verify secrets are mounted: `docker exec mariadb ls -la /run/secrets/`

**SSL certificate errors:**
- This is normal for self-signed certificates
- Accept the certificate warning in your browser
- For production, use a proper SSL certificate from Let's Encrypt or similar

**Permission errors:**
- Ensure data directory has correct permissions:
  ```bash
  sudo chown -R $USER:$USER /home/aarustam/data
  ```
