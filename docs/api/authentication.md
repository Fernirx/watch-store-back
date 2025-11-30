# Authentication

This guide explains how authentication works in the Tawatch Backend API.

---

## JWT Bearer Token

Most endpoints require authentication using JWT (JSON Web Token) tokens.

### How It Works

1. User sends credentials to the login endpoint
2. Server validates credentials and returns a JWT token
3. Client includes the token in subsequent requests
4. Server validates the token and processes the request

---

## Obtaining a Token

### Login Endpoint

**Request:**

```http
POST /api/tawatch/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**

```json
{
  "message": "Login successful",
  "data": {
    "token": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "tokenType": "Bearer"
    },
    "user": {
      "id": 123,
      "username": "hung",
      "email": "hung@gmail.com",
      "roles": ["ADMIN"]
    }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

**Response Fields:**

| Field                | Description                           |
|----------------------|---------------------------------------|
| `token.accessToken`  | The JWT access token for API requests |
| `token.refreshToken` | Token for obtaining new access tokens |
| `token.tokenType`    | Token type (always "Bearer")          |
| `user.id`            | Unique user identifier                |
| `user.username`      | User's display name                   |
| `user.email`         | User's email address                  |
| `user.roles`         | Array of user roles                   |

---

## Using the Token

### In HTTP Requests

Include the token in the `Authorization` header:

```http
GET /api/tawatch/products
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Format

```
Authorization: Bearer <token>
```

**Important:**
- The word "Bearer" must be included before the token
- There must be a space between "Bearer" and the token
- Use the `accessToken` from login response, not `refreshToken`

---

## Using Authentication in Swagger UI

### Step-by-Step Guide

1. **Click the Authorize button**
   - Look for the lock icon (🔒) at the top of Swagger UI
   - Click it to open the authentication dialog

2. **Enter your token**
   - Format: `Bearer <your-access-token-here>`
   - Example: `Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

3. **Click Authorize**
   - The dialog will close
   - All subsequent requests will automatically include the token

4. **Test an endpoint**
   - Try any protected endpoint
   - The token will be sent automatically

### Logging Out

To clear the token from Swagger UI:
1. Click the Authorize button again
2. Click **Logout**

---

## Token Expiration & Refresh

### Access Token Expiration

Access tokens expire after a short period (typically 15-30 minutes).

### Refresh Token Security

For enhanced security, refresh tokens are rotated on each use:

- When you use a refresh token, you get a **new refresh token**
- The old refresh token becomes invalid
- This prevents token reuse if compromised

### Refresh Token Endpoint

When access token expires, use the refresh token to get a new one:

**Request:**

```http
POST /api/tawatch/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**

```json
{
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer"
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Handling Expired Tokens

When a token expires, you'll receive a `401 Unauthorized` response:

```json
{
  "message": "Token has expired",
  "code": "TOKEN_EXPIRED",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products"
}
```

**Solution:** Use the refresh token to get a new access token.

---

## Authorization

### Role-Based Access Control

Access to certain endpoints may require specific roles:

- **ADMIN** - Administrative access 

### Permission Errors

When accessing unauthorized resources, you'll receive a `403 Forbidden` response:

```json
{
  "message": "Insufficient permissions",
  "code": "FORBIDDEN",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/admin/users"
}
```

---

## Security Best Practices

1. **Never expose tokens** - Don't log or display tokens in plain text
2. **Use HTTPS** - Always use secure connections in production
3. **Store securely** - Keep tokens in secure storage (HttpOnly cookies for web apps)
4. **Rotate regularly** - Log out and re-authenticate periodically
5. **Validate expiration** - Check token expiration before making requests
---

## Troubleshooting

### Common Issues

**401 Unauthorized - Missing token**
```json
{
  "message": "No authorization token provided",
  "code": "UNAUTHORIZED",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products"
}
```
**Solution:** Include the `Authorization` header with a valid access token.

**401 Unauthorized - Invalid token**
```json
{
  "message": "Invalid token",
  "code": "INVALID_TOKEN",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products"
}
```
**Solution:** Verify the token format and request a new token.

**401 Unauthorized - Expired token**
```json
{
  "message": "Token has expired",
  "code": "TOKEN_EXPIRED",
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/tawatch/products"
}
```
**Solution:** Use the refresh token endpoint to get a new access token.

---

## Next Steps

- [API Conventions](conventions.md) - Learn about API standards
- [Testing APIs](testing.md) - Test authenticated endpoints
- [API Overview](overview.md) - Return to API overview