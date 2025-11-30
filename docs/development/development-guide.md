# Development Guide

This guide provides comprehensive instructions for developers working on the Tawatch Backend codebase, covering setup, workflows, best practices, and common development tasks.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Environment Setup](#development-environment-setup)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Code Style and Best Practices](#code-style-and-best-practices)
- [Debugging](#debugging)
- [Git Workflow](#git-workflow)
- [Useful Commands](#useful-commands)
- [Common Issues](#common-issues)

---

## Prerequisites

Before starting development, ensure you have the necessary tools installed. Choose between Docker or local development:

### Option 1: Docker (Recommended)

**Required:**
- **Git** - Version control
- **Docker Desktop** (Windows/macOS) or **Docker Engine + Docker Compose** (Linux)
- **IDE** - IntelliJ IDEA, VS Code, or Eclipse (for code editing)

**Why Docker?**
- MySQL runs in container (no local installation needed)
- Consistent environment across all platforms
- Easy cleanup and reset
- Isolated from your local system

### Option 2: Local Development

**Required:**
- **Git** - Version control
- **JDK 21+** - Java Development Kit
- **Maven 3.8+** - Build tool
- **MySQL 8.x** - Database server
- **IDE** - IntelliJ IDEA, VS Code, or Eclipse

**Verify Installations:**

```bash
# Check Java version
java -version
# Should show: Java 21 or higher

# Check Maven version
mvn -version
# Should show: Maven 3.8 or higher

# Check Git version
git --version

# Check Docker (if using Docker)
docker --version
docker compose version
```

---

## Development Environment Setup

### 1. Clone the Repository

```bash
# Clone via HTTPS
git clone https://github.com/Fernirx/tawatch-backend.git

# OR clone via SSH (recommended for contributors)
git clone git@github.com:Fernirx/tawatch-backend.git

# Navigate to project directory
cd tawatch-backend
```

### 2. Choose Your Development Approach

#### Option A: Docker Development (Recommended)

**Setup:**

1. **Copy configuration files**
   ```bash
   # Copy environment variables
   cp .env.example .env

   # Copy Docker profile
   cp tawatch-starter/src/main/resources/application.example.yml \
      tawatch-starter/src/main/resources/application-docker.yml
   ```

2. **Edit configuration if needed**
   ```bash
   # Edit .env file
   nano .env  # Linux/macOS
   notepad .env  # Windows
   ```

3. **Start development environment**

   **Linux/macOS:**
   ```bash
   # Build and start containers
   ./bin/linux/build.sh
   ./bin/linux/start.sh

   # Or manually:
   docker compose build
   docker compose up
   ```

   **Windows:**
   ```bash
   # Build and start containers
   bin\win\build.bat
   bin\win\start.bat

   # Or manually:
   docker compose build
   docker compose up
   ```

4. **Verify it's running**
   ```bash
   # Check health endpoint
   curl http://localhost:8080/api/tawatch/actuator/health
   ```

**Note:** MySQL is included in `docker-compose.yml` - no separate database installation needed.

#### Option B: Local Development

**Setup:**

1. **Start MySQL server**
   ```bash
   # Windows
   net start MySQL80

   # macOS
   brew services start mysql

   # Linux
   sudo systemctl start mysql
   ```

2. **Create database**
   ```bash
   # Login to MySQL
   mysql -u root -p

   # Create database
   CREATE DATABASE tawatch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;

   # Create user (optional but recommended)
   CREATE USER 'tawatch_user'@'localhost' IDENTIFIED BY 'your_password';
   GRANT ALL PRIVILEGES ON tawatch.* TO 'tawatch_user'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

3. **Copy and configure application settings**
   ```bash
   # Copy example configuration
   cp tawatch-starter/src/main/resources/application.example.yml \
      tawatch-starter/src/main/resources/application-local.yml
   ```

4. **Edit `application-local.yml`** with your database credentials:
   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/tawatch?useUnicode=true&characterEncoding=utf8mb4
       username: tawatch_user
       password: your_password
   ```

5. **Build the project**
   ```bash
   mvn clean install
   ```

6. **Run the application**
   ```bash
   mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local
   ```

### 3. IDE Setup

#### IntelliJ IDEA

1. **Import Project**
   - File → Open → Select root `pom.xml` → Open as Project
   - Wait for Maven to download dependencies

2. **Configure JDK**
   - File → Project Structure → Project → SDK → Select JDK 21+

3. **Install Recommended Plugins**
   - Lombok Plugin
   - SonarLint (code quality)
   - GitToolBox

4. **Create Run Configuration**
   - Run → Edit Configurations → + → Spring Boot
   - Main class: `vn.fernirx.tawatch.starter.TawatchApplication`
   - Active profiles: `local` (for local dev) or `docker` (for Docker)
   - Module: `tawatch-starter`

#### VS Code

1. **Install Extensions**
   - Extension Pack for Java (Microsoft)
   - Spring Boot Extension Pack (VMware)
   - Lombok Annotations Support

2. **Open project**
   - File → Open Folder → Select `tawatch-backend`

3. **Configure launch.json**
   ```json
   {
     "type": "java",
     "name": "Tawatch Application",
     "request": "launch",
     "mainClass": "vn.fernirx.tawatch.starter.TawatchApplication",
     "projectName": "tawatch-starter",
     "args": "--spring.profiles.active=local"
   }
   ```

#### Eclipse

1. **Import Project**
   - File → Import → Maven → Existing Maven Projects
   - Select project root directory → Finish

2. **Configure JDK**
   - Project → Properties → Java Compiler → Set to 21

3. **Run Configuration**
   - Right-click on `TawatchApplication.java` → Run As → Spring Boot App

---

## Project Structure

```
tawatch-backend/
├── .env.example                           # Environment variables template
├── docker-compose.yml                     # Docker services configuration
├── Dockerfile                             # Application container definition
├── pom.xml                                # Parent POM (multi-module)
├── docs/                                  # Documentation
│   ├── api/                              # API documentation
│   ├── architecture/                     # Architecture docs
│   ├── development/                      # Development guides
│   └── setup/                            # Installation & configuration
├── bin/                                   # Helper scripts
│   ├── linux/                            # Linux/macOS scripts
│   │   ├── build.sh
│   │   ├── start.sh
│   │   ├── stop.sh
│   │   └── access.sh
│   └── win/                              # Windows scripts
│       ├── build.bat
│       ├── start.bat
│       ├── stop.bat
│       └── access.bat
└── tawatch-starter/                       # Main application module
    ├── pom.xml                           # Module POM
    └── src/
        ├── main/
        │   ├── java/vn/fernirx/tawatch/starter/
        │   │   └── TawatchApplication.java  # Main application class
        │   └── resources/
        │       ├── application.yml          # Main configuration
        │       ├── application.example.yml  # Configuration template
        │       ├── application-local.yml    # Local profile (create from example)
        │       └── application-docker.yml   # Docker profile (create from example)
        └── test/                            # Test sources
```

**Key Directories:**
- `tawatch-starter/` - Main Spring Boot application module
- `docs/` - All project documentation
- `bin/` - Helper scripts for Docker operations
- `src/main/resources/` - Configuration files

---

## Configuration

Tawatch Backend uses **Spring Profiles** and **Environment Variables** for configuration management.

### Spring Profiles

- **`local`** - For local Maven development
- **`docker`** - For Docker environments

### Configuration Files

| File | Purpose |
|------|---------|
| `application.yml` | Base configuration (committed) |
| `application.example.yml` | Configuration template (committed) |
| `application-local.yml` | Local development config (create from example, not committed) |
| `application-docker.yml` | Docker environment config (create from example, not committed) |
| `.env` | Docker environment variables (create from `.env.example`, not committed) |

### Creating Configuration Files

**For Docker:**
```bash
# Copy environment file
cp .env.example .env

# Copy Docker profile
cp tawatch-starter/src/main/resources/application.example.yml \
   tawatch-starter/src/main/resources/application-docker.yml

# Edit as needed
nano .env  # or notepad .env on Windows
```

**For Local Development:**
```bash
# Copy local profile
cp tawatch-starter/src/main/resources/application.example.yml \
   tawatch-starter/src/main/resources/application-local.yml

# Edit database credentials and other settings
nano tawatch-starter/src/main/resources/application-local.yml
```

### Key Configuration Properties

**Server Configuration:**
```yaml
server:
  port: ${SERVER_PORT:8080}
  servlet:
    context-path: ${SERVER_CONTEXT_PATH:/api/tawatch}
```

**Database Configuration:**
```yaml
spring:
  datasource:
    url: jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:tawatch}
    username: ${DB_USERNAME:tawatch_user}
    password: ${DB_PASSWORD:tawatch_pass}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
```

For complete configuration reference, see [Configuration Guide](../setup/configuration.md).

---

## Running the Application

### Method 1: Docker Compose (Recommended)

**Start:**
```bash
# Linux/macOS
./bin/linux/start.sh

# Windows
bin\win\start.bat

# Or manually
docker compose up
```

**Stop:**
```bash
# Linux/macOS
./bin/linux/stop.sh

# Windows
bin\win\stop.bat

# Or manually
docker compose down
```

**View logs:**
```bash
docker compose logs -f app
```

**Access container shell:**
```bash
# Linux/macOS
./bin/linux/access.sh

# Windows
bin\win\access.bat

# Or manually
docker compose exec app /bin/bash
```

### Method 2: Maven

**From command line:**
```bash
# Run with local profile
mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local

# Run with debug enabled
mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

**Build and run JAR:**
```bash
# Build
mvn clean package -DskipTests

# Run
java -jar tawatch-starter/target/tawatch-starter-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

### Method 3: IDE

**IntelliJ IDEA:**
1. Run → Edit Configurations → Select your Spring Boot configuration
2. Set Active profiles: `local` or `docker`
3. Click Run (Shift+F10) or Debug (Shift+F9)

**VS Code:**
1. Open Run and Debug (Ctrl+Shift+D)
2. Select "Tawatch Application"
3. Press F5 to start

**Eclipse:**
1. Right-click on `TawatchApplication.java`
2. Run As → Spring Boot App

### Verify Application

**Health check:**
```bash
curl http://localhost:8080/api/tawatch/actuator/health
```

**Expected response:**
```json
{
  "status": "UP"
}
```

**Swagger UI:**
```
http://localhost:8080/api/tawatch/swagger-ui/index.html
```

---

## Development Workflow

### 1. Branch Strategy

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Create bugfix branch
git checkout -b bugfix/issue-description

# Create docs branch
git checkout -b docs/documentation-update
```

### 2. Making Changes

1. **Write code following project conventions**
2. **Run tests to ensure nothing breaks**
   ```bash
   mvn test
   ```
3. **Build the project**
   ```bash
   mvn clean install
   ```

### 3. Commit Guidelines

**Commit message format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```bash
git commit -m "feat(products): add product search endpoint"
git commit -m "fix(auth): resolve JWT token expiration issue"
git commit -m "docs(api): update authentication guide"
```

### 4. Push and Create Pull Request

```bash
# Push branch
git push origin feature/your-feature-name

# Create PR via GitHub CLI (if installed)
gh pr create --title "Add product search feature" --body "Description here"
```

---

## Testing

### Running Tests

**All tests:**
```bash
mvn test
```

**Specific test class:**
```bash
mvn test -Dtest=ProductServiceTest
```

**With coverage:**
```bash
mvn clean test jacoco:report
# View report at: target/site/jacoco/index.html
```

### Test Structure

```
src/test/java/vn/fernirx/tawatch/starter/
├── unit/              # Unit tests
├── integration/       # Integration tests
└── e2e/              # End-to-end tests
```

### Testing with Swagger UI

1. Start application
2. Navigate to `http://localhost:8080/api/tawatch/swagger-ui/index.html`
3. Click "Authorize" for protected endpoints
4. Try out API endpoints interactively

For complete testing guide, see [API Testing Guide](../api/testing.md).

---

## Code Style and Best Practices

### Coding Standards

1. **Follow Java naming conventions**
   - Classes: `PascalCase`
   - Methods/variables: `camelCase`
   - Constants: `UPPER_SNAKE_CASE`
   - Packages: `lowercase`

2. **Use meaningful names**
   ```java
   // Good
   public Product findProductById(Long productId) { ... }

   // Bad
   public Product get(Long id) { ... }
   ```

3. **Keep methods short**
   - Aim for < 50 lines per method
   - Single responsibility principle

4. **Write self-documenting code**
   ```java
   // Good - clear without comments
   boolean isProductAvailable = product.getStock() > 0 && product.isActive();

   // Bad - needs comment to understand
   boolean x = p.getStock() > 0 && p.getA();  // check if available
   ```

### Best Practices

**✅ Do:**
- Use dependency injection
- Write unit tests for business logic
- Handle exceptions appropriately
- Use DTOs for API requests/responses
- Validate all user inputs
- Use transactions for data modifications
- Log important operations
- Document public APIs

**❌ Don't:**
- Use magic numbers or strings
- Catch exceptions without logging
- Return null (use `Optional<T>` instead)
- Expose JPA entities directly in controllers
- Ignore compiler warnings
- Commit commented-out code
- Hardcode configuration values

### Code Review Checklist

Before submitting PR:
- [ ] Code follows project conventions
- [ ] All tests pass
- [ ] New tests added for new features
- [ ] No unnecessary code or imports
- [ ] Proper error handling
- [ ] Documentation updated if needed
- [ ] No sensitive data in code

---

## Debugging

### Debug Mode

**Maven:**
```bash
mvn spring-boot:run -pl tawatch-starter \
  -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

**IDE:**
- IntelliJ: Click Debug button (Shift+F9)
- VS Code: Press F5 with debugger configured
- Eclipse: Right-click → Debug As → Spring Boot App

**Docker:**
```bash
# Add to docker-compose.yml (app service):
environment:
  JAVA_TOOL_OPTIONS: "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
ports:
  - "5005:5005"

# Then connect IDE debugger to localhost:5005
```

### Logging

**Application logs:**
```bash
# Docker
docker compose logs -f app

# Local
tail -f logs/application.log
```

**Change log levels** in `application-local.yml` or `application-docker.yml`:
```yaml
logging:
  level:
    root: INFO
    vn.fernirx.tawatch: DEBUG
    org.springframework.web: DEBUG
    org.hibernate.SQL: DEBUG
```

### Common Debug Scenarios

**Database queries:**
```yaml
spring:
  jpa:
    show-sql: true
    properties:
      hibernate:
        format_sql: true

logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
```

**HTTP requests:**
```yaml
logging:
  level:
    org.springframework.web: DEBUG
    org.springframework.web.servlet.mvc.method.annotation: TRACE
```

---

## Git Workflow

### Daily Workflow

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/new-feature

# 3. Make changes and commit
git add .
git commit -m "feat: add new feature"

# 4. Push to remote
git push origin feature/new-feature

# 5. Create pull request on GitHub
```

### Syncing with Main

```bash
# Update your branch with latest main
git checkout main
git pull origin main
git checkout feature/your-feature
git rebase main

# Or merge instead of rebase
git merge main
```

### Undo Changes

```bash
# Discard uncommitted changes
git restore <file>

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

---

## Useful Commands

### Maven Commands

```bash
# Clean build
mvn clean install

# Skip tests
mvn clean install -DskipTests

# Run application
mvn spring-boot:run -pl tawatch-starter

# Run tests
mvn test

# Run specific test
mvn test -Dtest=ProductServiceTest

# Display dependency tree
mvn dependency:tree

# Update dependencies
mvn dependency:resolve -U
```

### Docker Commands

```bash
# Build images
docker compose build

# Start containers
docker compose up -d

# Stop containers
docker compose down

# View logs
docker compose logs -f app

# Access container
docker compose exec app /bin/bash

# Restart containers
docker compose restart

# Clean everything (⚠️ deletes volumes)
docker compose down -v
```

### Database Commands

**Connect to MySQL in Docker:**
```bash
docker compose exec db mysql -u root -p
```

**Connect to local MySQL:**
```bash
mysql -u tawatch_user -p tawatch
```

**Useful SQL:**
```sql
-- Show all tables
SHOW TABLES;

-- Describe table structure
DESCRIBE products;

-- Check database character set
SHOW VARIABLES LIKE 'character_set%';
```

---

## Common Issues

### Port Already in Use

**For Docker:**
```bash
# Edit .env file and change HOST_PORT
HOST_PORT=8081

# Restart containers
docker compose down
docker compose up
```

**For local development:**
```yaml
# Edit application-local.yml
server:
  port: 8081
```

### Database Connection Failed

**Check MySQL is running:**
```bash
# Docker
docker compose ps

# Local
# Windows: net start MySQL80
# macOS: brew services list
# Linux: systemctl status mysql
```

**Verify credentials:**
- Check `application-local.yml` or `application-docker.yml`
- Ensure database exists
- Test connection: `mysql -u tawatch_user -p`

### Maven Build Fails

```bash
# Clean and retry
mvn clean install -U

# Skip tests temporarily
mvn clean install -DskipTests

# Clear local Maven repository
rm -rf ~/.m2/repository
mvn clean install
```

### IDE Not Recognizing Lombok

**IntelliJ IDEA:**
1. Install Lombok Plugin
2. File → Settings → Build, Execution, Deployment → Compiler → Annotation Processors
3. Enable "Enable annotation processing"

**VS Code:**
1. Install "Lombok Annotations Support for VS Code"
2. Restart VS Code

**Eclipse:**
1. Download `lombok.jar`
2. Run: `java -jar lombok.jar`
3. Select Eclipse installation directory

### Container Build Fails

```bash
# Rebuild without cache
docker compose build --no-cache

# Clean Docker system
docker system prune -f

# Complete reset (⚠️ deletes volumes)
docker compose down -v
docker system prune -af
docker compose build --no-cache
docker compose up
```

---

## Additional Resources

- [Installation Guide](../setup/installation.md) - Initial setup and deployment
- [Configuration Guide](../setup/configuration.md) - Environment configuration
- [API Overview](../api/overview.md) - API documentation
- [Database Schema](../architecture/database-schema.md) - Database structure
- [Module Architecture](../architecture/module-architecture.md) - Architecture overview

---

**Need help?** Check existing documentation or ask the team in project discussions.
