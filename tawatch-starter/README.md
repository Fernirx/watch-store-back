# Tawatch Starter

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.7-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)

**Main Spring Boot starter module for the Tawatch backend application.**

This module serves as the entry point of the Tawatch e-commerce watch store backend. It contains the main application class, base configuration, and orchestrates other modules in the project.

---

## Overview

The `tawatch-starter` module is responsible for:

* **Application Bootstrap** – Starts the backend via `@SpringBootApplication`.
* **Base Configuration** – Defines the active profile and common settings.
* **Database Migrations** – Includes initial Flyway scripts.
* **Integration Testing** – Ensures Spring context loads correctly.
* **Multi-Module Orchestration** – Integrates feature modules in the parent project.

This module is intentionally lightweight, focused on bootstrapping the application.

**Note:** This module is never run standalone; it is designed to bootstrap the full backend application.

---

## Module Structure

```plaintext
tawatch-starter/
├── README.md                                   # Module-level README
├── src/
│   ├── main/
│   │   ├── java/vn/fernirx/tawatch/starter/
│   │   │   └── TawatchApplication.java        # Entry point of the module
│   │   └── resources/
│   │       ├── application.yaml               # Profile selector (switches between profile files)
│   │       ├── application.example.yaml       # Example configuration file
│   │       └── db/migration/
│   │           └── V1__init_schema.sql        # Initial Flyway migration script
│   └── test/
│       └── java/vn/fernirx/tawatch/starter/
│           └── TawatchApplicationTests.java   # Unit & integration tests
```

---

## Key Components

### `TawatchApplication.java`

Main class annotated with `@SpringBootApplication`. Responsibilities:

* Enable Spring Boot auto-configuration.
* Trigger component scanning for all modules.
* Serve as entry point when running the full application.

---

### `application.yaml`

* Defines active profile selector.
* Switches between profile-specific files such as `application-local.yaml` or `application-docker.yaml`.

---

### `application.example.yaml`

* Serves as a template for creating environment-specific configuration files.
* Developers copy this file to create `application-local.yaml`, `application-docker.yaml`, etc.

---

### `db/migration/V1__init_schema.sql`

* Flyway migration script for initializing the database schema.
* Ensures consistent database setup across environments.

---

## Dependencies

This module includes minimal core dependencies:

* **spring-boot-starter-web** – REST APIs and embedded Tomcat.
* **spring-boot-starter-test** – JUnit, Spring Test, Mockito.

Business logic dependencies are added via feature modules in the parent project.

**Note:** No business logic is implemented here; feature modules provide the main functionality.

---

## Profiles

The module uses Spring profiles to separate environments:

* `local` – For local development.
* `docker` – For Dockerized deployment.

Profile-specific configuration files are stored alongside `application.yaml`.
Refer to the [Configuration Guide](../docs/setup/configuration.md) for details.

---

## Testing

Integration and unit tests ensure:

* Spring application context loads correctly.
* Auto-configurations are applied properly.
* No configuration conflicts exist.

**Test class:** `TawatchApplicationTests.java`

---

## Related Documentation

* [Parent Project README](../README.md) – Complete project documentation.
* [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/3.5.7/reference/html/)
* [Spring Boot Maven Plugin](https://docs.spring.io/spring-boot/docs/3.5.7/maven-plugin/reference/html/)

---

## Contact

* **Author:** Phạm Huỳnh Thanh Hưng
* **Email:** [anhtuhungdeveloper@gmail.com](mailto:anhtuhungdeveloper@gmail.com)
* **GitHub:** [github.com/Fernirx](https://github.com/Fernirx)
