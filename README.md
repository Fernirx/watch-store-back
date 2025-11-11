# Tawatch Backend

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-blue.svg)](https://www.mysql.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**RESTful backend API for a modular e-commerce watch store, built with Spring Boot 3.5.7.**
Provides essential functionality for managing products, orders, customers, payments, and related operations, ready for integration with web application.

## Table of Contents

* [Introduction](#introduction)
* [Key Features](#key-features)
* [Technologies](#technologies)
* [Prerequisites](#prerequisites)
* [Project Structure](#project-structure)
* [Modules](#modules)
* [Profiles & Configuration](#profiles--configuration)
* [Run & Build](#run--build)
* [Testing](#testing)
* [Security & Health](#security--health)
* [API Documentation](#api-documentation)
* [License](#license)
* [Contact](#contact)

---

## Introduction

Tawatch Backend aims to provide a clean, maintainable, and production-ready backend for an online watch store. The project emphasizes modular architecture, code clarity, and scalability, making it suitable for both learning and real-world deployment.

---

## Key Features

**Core Features:**
* **Product Management:** CRUD operations, inventory tracking, category management
* **Order Processing:** Cart management, order status tracking, order history
* **Customer Management:** User profiles, address book, order history
* **Payment Integration:** Support for COD, Momo
* **Role-based Access Control:** Admin, Customer, Manager roles with specific permissions

**Supporting Features:**
* Supports Docker, Actuator health monitoring, and OpenAPI documentation for easy integration.

---

## Technologies

* **Java 21** or higher
* **Spring Boot:** 3.5.7
* **MySQL 8.x** (or use Docker)
* **Maven 3.8+**
* **Docker & Docker Compose**

---

## Prerequisites

Ensure you have the following installed:

### Required
- **JDK 21+**
    - [Windows/macOS Download](https://www.oracle.com/java/technologies/downloads/)
    - Linux: `sudo apt install openjdk-21-jdk` (Ubuntu/Debian) or `sudo dnf install java-21-openjdk` (Fedora/RHEL)

- **Maven 3.8+**
    - [Installation Guide](https://maven.apache.org/install.html)
    - Linux: `sudo apt install maven` (Ubuntu/Debian) or `sudo dnf install maven` (Fedora/RHEL)

- **Git**
    - [Download](https://git-scm.com/downloads)
    - Linux: `sudo apt install git` (Ubuntu/Debian) or `sudo dnf install git` (Fedora/RHEL)

### Database / Environment (Choose One)
- **MySQL 8.x** - For local database
    - [Windows/macOS Download](https://dev.mysql.com/downloads/mysql/)
    - Linux: `sudo apt install mysql-server` (Ubuntu/Debian) or `sudo dnf install mysql-server` (Fedora/RHEL)

- **Docker Desktop** - Includes Docker Compose (Recommended)
    - [Windows/macOS Download](https://www.docker.com/products/docker-desktop/)
    - Linux:
        - [Docker Engine](https://docs.docker.com/engine/install/)
        - [Docker Compose](https://docs.docker.com/compose/install/)
        - Or: `sudo apt install docker.io docker-compose` (Ubuntu/Debian)

> **Note:** Using Docker is recommended as it simplifies setup and ensures consistency across environments.

---

## Project Structure

```plaintext
tawatch-backend/
├── tawatch-starter/        # Main Spring Boot starter module (entry point)
│   └── README.md           # Module-level documentation
├── README.md               # Project-level documentation
├── Dockerfile              # Docker image build configuration
├── docker-compose.yml     # Docker Compose orchestration file
├── .env.example            # Example environment variables (do not commit secrets)
├── .gitignore              # Git ignore rules
├── .dockerignore           # Docker ignore rules
└── pom.xml                 # Maven project descriptor (root POM)
```

---

## Modules

| Module             | Description                                                                                |
|--------------------|--------------------------------------------------------------------------------------------|
| `tawatch-starter`  | Main application entry point, contains the `@SpringBootApplication` and base configuration |
| *(future modules)* | Feature modules (e.g., `tawatch-core`, `tawatch-domain`, etc.) to be added later           |

---

## Profiles & Configuration

The project uses **Spring profiles** to manage environment-specific settings.

Create environment-specific config files from the example:

- `local` — for local development (`application.example.yml` → `application-local.yml`)
- `docker` — for Dockerized environments (`application.example.yml` → `application-docker.yml`)

The base `application.yml` only contains the active profile selector.

Each profile supports variable substitution from the `.env.example` file  
(for example, `DB_HOST`, `DB_PORT`, `SERVER_PORT`, etc.).  
Developers should create a real `.env` file based on `.env.example` when running locally or in CI/CD.

---

## Run & Build

### 1. Clone repository

```bash
git clone https://github.com/Fernirx/tawatch-backend.git
cd tawatch-backend
```

---

### 2. Prepare configuration

Copy example configuration files to create your local environment setup:

```bash
# Copy example application config
cp tawatch-starter/src/main/resources/application.example.yml tawatch-starter/src/main/resources/application-local.yml
# Copy environment variables template
cp .env.example .env
```

Edit these files with your local or CI/CD environment settings.

---

### 3. Run locally with Maven

```bash
# Build the project
mvn clean install

# Run application (starter module)
mvn spring-boot:run -pl tawatch-starter -Dspring-boot.run.profiles=local
```

The API will be available at: [http://localhost:8080/api/tawatch](http://localhost:8080/api/tawatch).

---

### 4. Run with Docker Compose

#### On Linux / macOS

```bash
# Build images first
./bin/linux/build.sh

# Then start containers
./bin/linux/start.sh
```

or manually without scripts:

```bash
docker compose build
docker compose up
```

#### On Windows

```bash
# Build images first
bin\win\build.bat

# Then start containers
bin\win\start.bat
```

or manually without scripts:

```bash
docker compose build
docker compose up
```
> Always build before starting to ensure images are up-to-date.

Additional helper scripts are provided for convenience:

| Script   | Description                            |
|----------|----------------------------------------|
| `build`  | Build images                           |
| `start`  | Start containers (builds if needed)    |
| `stop`   | Stop and remove containers             |
| `access` | Access container shell (for debugging) |

---

### 5. Verify Application

Once the application is running:

* **Swagger UI:** [http://localhost:8080/api/tawatch/swagger-ui/index.html](http://localhost:8080/api/tawatch/swagger-ui/index.html).
* **Health Check:** [http://localhost:8080/api/tawatch/actuator/health](http://localhost:8080/api/tawatch/actuator/health).

---

## Testing

Testing follows a standard **JUnit + Spring Boot Test** setup.

* Unit tests cover services and utility classes.
* Integration tests validate repository and controller behavior.
* Use `@SpringBootTest` for context-based testing.

Run all tests:

```bash
mvn test
```

* Run a specific test:

```bash
mvn -Dtest=ProductServiceTest test
```

---

## Security & Health

Security is handled via **Spring Security with JWT (Bearer tokens)**, providing:

* Authentication & authorization layers
* Role-based access control for endpoints
* Password encryption via `BCryptPasswordEncoder`

Health endpoints are exposed via **Actuator**, e.g.:

```
GET /actuator/health
```

Sensitive endpoints can be protected under restricted access for safety.

---

## API Documentation

Interactive API documentation is available via Swagger UI:

* **Swagger UI:** [http://localhost:8080/api/tawatch/swagger-ui/index.html](http://localhost:8080/swagger-ui/index.html)
* **OpenAPI JSON/YAML:** [http://localhost:8080/api/tawatch/v3/api-docs](http://localhost:8080/v3/api-docs)

OpenAPI specification is automatically generated and updated at runtime.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For questions, issues, or contributions:

* **Author:** Phạm Huỳnh Thanh Hưng
* **Email:** [anhtuhungdeveloper@gmail.com](mailto:anhtuhungdeveloper@gmail.com)
* **GitHub:** [github.com/Fernirx](https://github.com/Fernirx)
