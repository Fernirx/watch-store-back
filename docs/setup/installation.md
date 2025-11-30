# Installation & Deployment Guide

This comprehensive guide will help you install prerequisites, set up the development environment, and deploy Tawatch Backend.

## Prerequisites

### Choose Your Development Environment

#### Option 1: Docker (Recommended) ⭐

**What you need:**

1. **Git** (to clone repository)
    - **All platforms:** [Download](https://git-scm.com/downloads)
    - **Linux:**
        - Ubuntu/Debian: `sudo apt install git`
        - Fedora/RHEL: `sudo dnf install git`

2. **Docker Desktop or Docker Engine + Docker Compose**
    - **Windows/macOS:** [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
    - **Linux:**
        - [Docker Engine Installation](https://docs.docker.com/engine/install/)
        - [Docker Compose Installation](https://docs.docker.com/compose/install/)
        - Or quick install: `sudo apt install docker.io docker-compose` (Ubuntu/Debian)

**Why Docker?**
- ✅ **No JDK required** - Java runs inside container
- ✅ **No Maven required** - Maven runs inside container
- ✅ **No MySQL required** - Database included in docker-compose.yml
- ✅ Consistent environment across all platforms
- ✅ Easy cleanup and reset
- ✅ Isolated from your local system

---

#### Option 2: Local Development with Maven

**What you need:**

1. **JDK 21+**
    - **Windows/macOS:** [Download from Oracle](https://www.oracle.com/java/technologies/downloads/)
    - **Linux:**
        - Ubuntu/Debian: `sudo apt install openjdk-21-jdk`
        - Fedora/RHEL: `sudo dnf install java-21-openjdk`

2. **Maven 3.8+**
    - **All platforms:** [Installation Guide](https://maven.apache.org/install.html)
    - **Linux:**
        - Ubuntu/Debian: `sudo apt install maven`
        - Fedora/RHEL: `sudo dnf install maven`

3. **Git**
    - **All platforms:** [Download](https://git-scm.com/downloads)
    - **Linux:**
        - Ubuntu/Debian: `sudo apt install git`
        - Fedora/RHEL: `sudo dnf install git`

4. **MySQL 8.x**
    - **Windows/macOS:** [Download MySQL](https://dev.mysql.com/downloads/mysql/)
    - **Linux:**
        - Ubuntu/Debian: `sudo apt install mysql-server`
        - Fedora/RHEL: `sudo dnf install mysql-server`

**Use this option if:**
- You already have JDK and Maven installed
- You prefer managing database manually
- You need to use existing local databases
- You want direct control over Java environment

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Fernirx/tawatch-backend.git
cd tawatch-backend
```

### 2. Verify Installation

Check that all prerequisites are installed correctly based on your chosen option:

#### For Docker Users

```bash
# Check Git version
git --version

# Check Docker version
docker --version
docker compose version
```

#### For Local Development Users

```bash
# Check Java version
java -version

# Check Maven version
mvn -version

# Check Git version
git --version

# Check MySQL (if installed)
mysql --version
```

You should see version numbers for each tool. If any command fails, please install the missing prerequisite.

---

## Detailed Deployment Options

### Option 1: Local Development with Maven

**Prerequisites:**
- JDK 21+
- Maven 3.8+
- MySQL 8.x running locally

**Steps:**

1. **Prepare configuration**

    ```bash
    cp tawatch-starter/src/main/resources/application.example.yml \
     tawatch-starter/src/main/resources/application-local.yml
    ```

    Edit `application-local.yml` with your local database credentials.

2. **Build the project**

    ```bash
    mvn clean install
    ```

3. **Run the application**

    ```bash
    mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local
    ```

4. **Verify it's running**

    Visit [http://localhost:8080/api/tawatch/actuator/health](http://localhost:8080/api/tawatch/actuator/health)

---

### Option 2: Docker Compose (Recommended)

**Prerequisites:**
- Docker Desktop (Windows/macOS) or Docker Engine + Docker Compose (Linux)

**Important:** All `docker compose` commands must be run from the project root directory (where `docker-compose.yml` is located).

**Steps:**

1. **Prepare configuration**

    ```bash
    # Copy Docker profile configuration
    cp tawatch-starter/src/main/resources/application.example.yml \
     tawatch-starter/src/main/resources/application-docker.yml
    
    # Copy environment variables
    cp .env.example .env
    ```

    Edit `.env` if needed to customize ports and settings.

2. **Build and run**

    #### Linux / macOS:

    Using convenience scripts:

    ```bash
    # Build images
    ./bin/linux/build.sh
    
    # Start containers
    ./bin/linux/start.sh
    
    # Stop containers
    ./bin/linux/stop.sh
    
    # Access container shell (for debugging)
    ./bin/linux/access.sh
    ```

    Or manually:

    ```bash
    docker compose build
    docker compose up
    ```

    #### Windows:
    
    Using convenience scripts:
    
      ```bash
      # Build images
      bin\win\build.bat
      
      # Start containers
      bin\win\start.bat
      
      # Stop containers
      bin\win\stop.bat
      
      # Access container shell (for debugging)
      bin\win\access.bat
      ```
    
    Or manually:
    
      ```bash
      docker compose build
      docker compose up
      ```

3. **Verify it's running**

    Visit [http://localhost:8080/api/tawatch/actuator/health](http://localhost:8080/api/tawatch/actuator/health)

---

## Helper Scripts Reference

| Script | Linux/macOS             | Windows              | Description                          |
|--------|-------------------------|----------------------|--------------------------------------|
| Build  | `./bin/linux/build.sh`  | `bin\win\build.bat`  | Build Docker images                  |
| Start  | `./bin/linux/start.sh`  | `bin\win\start.bat`  | Start containers (builds if needed)  |
| Stop   | `./bin/linux/stop.sh`   | `bin\win\stop.bat`   | Stop and remove containers           |
| Access | `./bin/linux/access.sh` | `bin\win\access.bat` | Access container shell for debugging |

> **Important:** Always build images before starting to ensure they're up-to-date.

---

## Verifying Your Deployment

Once the application is running, verify these endpoints:

### Health Check
```
GET http://localhost:8080/api/tawatch/actuator/health
```

Expected response:
```json
{
  "status": "UP"
}
```

### Swagger UI (API Documentation)
```
http://localhost:8080/api/tawatch/swagger-ui/index.html
```

### OpenAPI Specification
```
http://localhost:8080/api/tawatch/v3/api-docs
```

---

## Troubleshooting Guide

### Working Directory Matters

**Important:** Most `docker compose` commands require running from the project root directory (where `docker-compose.yml` is located).

**Do this:**
```bash
cd /path/to/tawatch-backend
docker compose ps
```

**Not this:**
```bash
cd /path/to/tawatch-backend/bin/linux
docker compose ps  # This will fail!
```

---

### Port Already in Use

If you see "port already in use" error:

**For Local Maven:**
- Check running processes: `netstat -ano | findstr :PORT` (Windows) or `lsof -i :PORT` (Linux/Mac)
- Change `server.port` in `application-local.yml`

**For Docker:**
- Edit `HOST_PORT` in `.env` file
- Run `./bin/linux/stop.sh` (Linux/Mac) or `bin\win\stop.bat` (Windows) to stop and remove containers
- Run `./bin/linux/start.sh` (Linux/Mac) or `bin\win\start.bat` (Windows) to restart containers

### Database Connection Issues

**For Local Maven:**
- Verify MySQL is running: `mysql -u root -p`
- Check credentials in `application-local.yml`
- Ensure database exists

**For Docker:**
- Check container logs: `docker compose logs mysql`
- Verify database container status: `docker compose ps`
- Access database directly: `docker compose exec -it mysql mysql -u root -p`

## Container Build Fails

```bash
# Quick Fix (Safe - Keeps Data)
docker compose down
docker compose build --no-cache
docker compose up

# Medium Clean (Removes Containers & Networks)
docker compose down
docker system prune -f
docker compose build --no-cache
docker compose up

# Complete Reset (⚠️ DELETES ALL DATA - Use with caution!)
docker compose down -v
docker system prune -f
docker compose build --no-cache
docker compose up
```

## Common Issues

**Permission Errors (Linux/Mac):**
```bash
chmod +x bin/linux/*.sh
```

**Windows Script Issues:**
- Run PowerShell/CMD as Administrator
- Check Docker Desktop is running

**Docker Desktop Problems:**
- Restart Docker Desktop
- Check virtualization is enabled in BIOS

**Application Not Accessible:**
- Verify containers are running: `docker compose ps`
- Check application logs: `docker compose logs app`

---

## Production Deployment

For production deployments, consider:

1. **Use production-grade database** - Dedicated MySQL instance, not Docker
2. **Set secure credentials** - Use strong passwords, rotate regularly
3. **Enable HTTPS** - Use reverse proxy (nginx, Apache) with SSL/TLS
4. **Configure monitoring** - Use Actuator endpoints with Prometheus/Grafana
5. **Set up logging** - Configure centralized logging (ELK stack, etc.)
6. **Resource limits** - Set appropriate JVM heap size and Docker resource constraints
7. **Backup strategy** - Regular database backups with tested restore procedures

---

## Next Steps

After successful installation and deployment, proceed to:
- [Configuration Guide](configuration.md) - Set up your environment configuration
- [API Documentation](../api/overview.md) - Learn how to use Swagger UI and API