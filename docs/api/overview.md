# API Overview

This guide provides an overview of the Tawatch Backend API and how to access its documentation.

---

## Interactive API Documentation

Tawatch Backend uses **SpringDoc OpenAPI** to automatically generate interactive API documentation.

### Accessing Swagger UI

Once the application is running, access Swagger UI at:

```
http://localhost:8080/api/tawatch/swagger-ui/index.html
```

**Features:**
- **Browse all endpoints** - See all available API endpoints organized by controller
- **View request/response schemas** - Detailed information about request bodies and responses
- **Try it out** - Execute API calls directly from the browser
- **Authentication** - Test authenticated endpoints using JWT tokens
- **Download OpenAPI spec** - Export API specification in JSON/YAML format

---

## OpenAPI Specification

### Accessing the Raw Specification

The OpenAPI specification is available in multiple formats:

**JSON format:**
```
http://localhost:8080/api/tawatch/v3/api-docs
```

**YAML format:**
```
http://localhost:8080/api/tawatch/v3/api-docs.yaml
```

---

## API Endpoint Structure

All API endpoints follow this structure:

```
http://localhost:8080/api/tawatch/{resource}
```

### Base URL Components

- **Host:** `localhost:8080` (configurable via `HOST_PORT` in `.env`)
- **Context Path:** `/api/tawatch` (configurable via `SERVER_CONTEXT_PATH` in `.env`)
- **Resource Path:** Varies by endpoint (e.g., `/products`, `/orders`)

For details on changing these settings, see the [Configuration Guide](../setup/configuration.md).

---

## Documentation Guides

- **[API Conventions](conventions.md)** - RESTful patterns, response formats, and HTTP status codes
- **[Authentication](authentication.md)** - JWT authentication and authorization
- **[Testing APIs](testing.md)** - How to test APIs using Swagger UI, cURL, and Postman

---

## Additional Resources

- [Installation Guide](../setup/installation.md) - Set up the development environment
- [Configuration Guide](../setup/configuration.md) - Configure API settings
