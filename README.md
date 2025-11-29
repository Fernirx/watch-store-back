# Tawatch Backend

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-blue.svg)](https://www.mysql.com/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**RESTful backend API for a modular e-commerce watch store**

Provides essential functionality for managing products, orders, customers, payments, and related operations, ready for integration with web applications.

## Table of Contents
1. [Introduction](#introduction)
2. [Key Features](#key-features)
3. [Technologies](#technologies)
4. [Quick Start](#quick-start)
5. [Documentation](#documentation)
6. [License](#license)
7. [Contact](#contact)

---

## Introduction


Tawatch Backend is a comprehensive Spring Boot application designed to power modern e-commerce watch stores. Built with enterprise-grade architecture patterns, it provides a solid foundation for both learning advanced Spring Boot concepts and deploying production-ready applications.

**What makes Tawatch different:**
- Clean, modular architecture following Spring Boot best practices
- Production-ready security with JWT authentication and role-based access control
- Complete Docker support for streamlined deployment
- Comprehensive API documentation with Swagger/OpenAPI
- Ready for integration with any frontend framework
---

## Key Features

**Core Features:**
* **Product Management:** CRUD operations, inventory tracking, category management
* **Order Processing:** Cart management, order status tracking, order history
* **Customer Management:** User profiles, address book, order history
* **Payment Integration:** Support for COD, Momo
* **Role-based Access Control:** Three-tier role system (User, Staff, Admin) with specific permissions

**Supporting Features:**
* Docker support for easy deployment
* Spring Actuator health monitoring
* OpenAPI/Swagger documentation for API exploration

---

## Technologies

* **Java 21** or higher
* **Spring Boot:** 3.5.7
* **MySQL 8.x** (or use Docker)
* **Maven 3.8+**
* **Docker & Docker Compose**

---

## Quick Start

Below is an example of how to set up the project with docker.

1. **Clone & Setup**

   ```bash
   git clone https://github.com/Fernirx/tawatch-backend.git
   cd tawatch-backend

   # Copy configuration templates
   cp tawatch-starter/src/main/resources/application.example.yml \
      tawatch-starter/src/main/resources/application-docker.yml

   # Copy environment variables
   cp .env.example .env
   ```
2. **Configure Environment**

   Edit `.env` file with your database and JWT configurations

3. **Build & Run**

   ```bash
   # Build and start
   docker compose up --build
   ```

4. **Verify Installation**

    * **API Base:** [http://localhost:8080/api/tawatch](http://localhost:8080/api/tawatch)
    * **Swagger UI:** [http://localhost:8080/api/tawatch/swagger-ui/index.html](http://localhost:8080/api/tawatch/swagger-ui/index.html)
    * **Health Check:** [http://localhost:8080/api/tawatch/actuator/health](http://localhost:8080/api/tawatch/actuator/health)

For detailed installation instructions, see the [Installation Guide](docs/setup/installation.md).

---

## Documentation

Comprehensive documentation is available in the `docs/` directory:

* **[Architecture](docs/architecture/module-architecture.md)** - System architecture and design overview
* **[Database Schema](docs/architecture/database-schema.md)** - Database design and entity relationships
* **[Installation Guide](docs/setup/installation.md)** - Setup, prerequisites, and running the application
* **[Configuration](docs/setup/configuration.md)** - Environment setup and profiles
* **[Development](docs/development/development-guide.md)** - Project structure and development workflow
* **[API Documentation](docs/api/overview.md)** - Swagger UI and API usage
* **[Authentication](docs/api/authentication.md)** - Authentication and authorization

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contact

For questions, issues, or contributions:

* **Author:** Phạm Huỳnh Thanh Hưng
* **Email:** [anhtuhungdeveloper@gmail.com](mailto:anhtuhungdeveloper@gmail.com)
* **GitHub:** [github.com/Fernirx](https://github.com/Fernirx)