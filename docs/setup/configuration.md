# Configuration Guide

This guide explains how to configure Tawatch Backend for different environments using Spring profiles and environment variables.

## Spring Profiles

The project uses **Spring profiles** to manage environment-specific settings:

- `local` — For local development with Maven
- `docker` — For Dockerized environments (Recommended)

---

## Configuration Setup

### For Docker Environments (Recommended)

When using Docker, configuration is primarily managed through environment variables in the `.env` file.

#### Linux/macOS

1. **Create environment file**
   ```bash
   cp .env.example .env
   ```

2. **Edit configuration**
   ```bash
   # Using nano (beginner-friendly)
   nano .env
   ```

3. **View current configuration**
   ```bash
   cat .env
   ```

#### Windows

1. **Create environment file**
   ```cmd
   copy .env.example .env
   ```

2. **Edit configuration**
   ```cmd
   # Using Notepad
   notepad .env
   ```

3. **View current configuration**
   ```cmd
   type .env
   ```

### Available Environment Variables

| Variable                 | Description                      | Default Value  |
|--------------------------|----------------------------------|----------------|
| `HOST_PORT`              | Port exposed on host machine     | `8080`         |
| `SERVER_PORT`            | Internal application server port | `8080`         |
| `APP_NAME`               | Application name identifier      | `tawatch`      |
| `SPRING_PROFILES_ACTIVE` | Active Spring profile            | `docker`       |
| `SERVER_CONTEXT_PATH`    | API base context path            | `/api/tawatch` |
| `DB_HOST`                | Database host                    | `db`           |
| `DB_PORT`                | Database port                    | `3306`         |
| `DB_NAME`                | Database name                    | `tawatch`      |
| `DB_USERNAME`            | Database username                | `tawatch_user` |
| `DB_PASSWORD`            | Database password                | `tawatch_pass` |

---

## Common Configuration Changes

### Changing Application Port

#### Linux/macOS
```bash
# Edit .env file
nano .env

# Change this line:
HOST_PORT=8081
```

#### Windows
```cmd
# Edit .env file
notepad .env

# Change this line:
HOST_PORT=8081
```

### Changing Database Configuration

#### Linux/macOS
```bash
nano .env

# Change these lines:
DB_NAME=my_database
DB_USERNAME=my_user
DB_PASSWORD=my_secure_password
```

#### Windows
```cmd
notepad .env

# Change these lines:
DB_NAME=my_database
DB_USERNAME=my_user
DB_PASSWORD=my_secure_password
```

### Changing API Base Path

#### Linux/macOS
```bash
nano .env

# Change this line:
SERVER_CONTEXT_PATH=/api/myapp
```

#### Windows
```cmd
notepad .env

# Change this line:
SERVER_CONTEXT_PATH=/api/myapp
```

---

## Variable Substitution

The application configuration files support variable substitution from the `.env` file. For example:

```yaml
spring:
  application:
    name: ${APP_NAME:tawatch}

server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: ${SERVER_CONTEXT_PATH:/api/tawatch}
    encoding:
      charset: UTF-8
      enabled: true
      force: true
```

This allows you to change settings without modifying the configuration files directly.

---

## Profile Selection

### Docker Environment (Default)

In `docker-compose.yml`, the profile is set via environment variable:

```yaml
environment:
  SPRING_PROFILES_ACTIVE: ${SPRING_PROFILES_ACTIVE:-docker}
```

### Local Development

When running with Maven, specify the profile:

```bash
mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local
```

---

## Configuration Best Practices

1. **Never commit sensitive data** - Keep credentials in `.env` (ignored by git)
2. **Use example files** - Provide `.env.example` and `application.example.yml` templates
3. **Document all variables** - Keep this guide updated when adding new configuration
4. **Environment-specific settings** - Use profiles for different deployment scenarios
5. **Default values** - Always provide sensible defaults using `${VAR:default}` syntax
6. **Docker-first approach** - Use `.env` for configuration changes in containerized environments

---

## Applying Configuration Changes

After changing `.env`, restart the application:

#### Linux/macOS
```bash
./bin/linux/stop.sh
./bin/linux/start.sh
```

#### Windows
```cmd
bin\win\stop.bat
bin\win\start.bat
```

**Note:** Changing database configuration may require resetting the database:
```bash
docker compose down -v  # ⚠️ This deletes existing data
```

---

## File Locations

| File               | Linux/macOS                             | Windows                                 |
|--------------------|-----------------------------------------|-----------------------------------------|
| Environment        | `./.env`                                | `.\.env`                                |
| Docker Compose     | `./docker-compose.yml`                  | `.\docker-compose.yml`                  |
| Application Config | `./tawatch-starter/src/main/resources/` | `.\tawatch-starter\src\main\resources\` |