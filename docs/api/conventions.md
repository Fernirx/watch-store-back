# API Conventions

This guide explains the conventions and standards used across all Tawatch Backend APIs.

---

## RESTful Resource Endpoints

Most resources follow standard REST conventions:

| Method | Endpoint            | Description              |
|--------|---------------------|--------------------------|
| GET    | `/resources`        | List all resources       |
| GET    | `/resources/{id}`   | Get specific resource    |
| POST   | `/resources`        | Create new resource      |
| PUT    | `/resources/{id}`   | Update entire resource   |
| PATCH  | `/resources/{id}`   | Partial update resource  |
| DELETE | `/resources/{id}`   | Delete resource          |

---

## Query Parameters

Common query parameters for listing endpoints:

```
GET /resources?page=0&size=20&sort=createdAt,desc
```

| Parameter | Description                    | Example                |
|-----------|--------------------------------|------------------------|
| `page`    | Page number (0-indexed)        | `page=0`               |
| `size`    | Items per page                 | `size=20`              |
| `sort`    | Sort field and direction       | `sort=name,asc`        |
| `filter`  | Filter by field value          | `filter=status:ACTIVE` |

### Pagination

Paginated responses include metadata:

```json
{
  "message": "message",
  "data": {
    "content": [
      { "id": 1, "name": "Item 1" },
      { "id": 2, "name": "Item 2" }
    ],
    "page": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Sorting

Sort by multiple fields using comma-separated values:

```
GET /resources?sort=category,asc&sort=price,desc
```

---

## Response Format

### Success Response

```json
{
  "message": "message",
  "data": {
    "id": 1,
    "name": "Rolex Submariner",
    "price": 8500.00
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Response

```json
{
  "message": "Resource not found",
  "code": "RESOURCE_NOT_FOUND",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products/999"
}
```

### Validation Error Response

```json
{
  "message": "Validation failed",
  "code": "VALIDATION_ERROR",
  "details": [
    {
      "field": "email",
      "message": "must be a valid email address"
    },
    {
      "field": "price",
      "message": "must be greater than 0"
    }
  ],
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products/999"
}
```

---

## HTTP Status Codes

| Code | Description                  | When Used                                    |
|------|------------------------------|----------------------------------------------|
| 200  | OK                           | Successful GET, PUT, PATCH                   |
| 201  | Created                      | Successful POST (resource created)           |
| 204  | No Content                   | Successful DELETE                            |
| 400  | Bad Request                  | Invalid request format or validation error   |
| 401  | Unauthorized                 | Missing or invalid authentication token      |
| 403  | Forbidden                    | Authenticated but not authorized             |
| 404  | Not Found                    | Resource does not exist                      |
| 409  | Conflict                     | Resource already exists or state conflict    |
| 500  | Internal Server Error        | Server-side error                            |

---

### Standard Error Codes

| Code                  | Description                     |
|-----------------------|---------------------------------|
| `VALIDATION_ERROR`    | Request validation failed       |
| `RESOURCE_NOT_FOUND`  | Requested resource not found    |
| `UNAUTHORIZED`        | Authentication required         |
| `FORBIDDEN`           | Insufficient permissions        |
| `DUPLICATE_RESOURCE`  | Resource already exists         |
| `INTERNAL_ERROR`      | Server-side error               |

---

## Date and Time Format

All timestamps use **ISO 8601** format with UTC timezone:

```
2024-01-15T10:30:00Z
```

---

## Field Naming Convention

API fields use **camelCase** naming:

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "createdAt": "2024-01-15T10:30:00Z",
  "isActive": true
}
```

---

## Next Steps

- [Authentication](authentication.md) - Learn about API authentication
- [Testing APIs](testing.md) - How to test API endpoints
- [API Overview](overview.md) - Return to API overview