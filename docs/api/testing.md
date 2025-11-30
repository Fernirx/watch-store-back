# API Testing

This guide explains how to test the Tawatch Backend API using various tools.

---

## Testing with Swagger UI

Swagger UI provides the easiest way to test APIs directly from your browser.

### Step-by-Step Guide

1. **Navigate to Swagger UI**
   ```
   http://localhost:8080/api/tawatch/swagger-ui/index.html
   ```

2. **Find the endpoint**
   - Browse endpoints organized by controller
   - Click on the endpoint you want to test

3. **Authenticate (if required)**
   - Click the **Authorize** button (🔒)
   - Enter your JWT token: `Bearer <token>`
   - Click **Authorize**
   - See [Authentication Guide](authentication.md) for details

4. **Try it out**
   - Click **Try it out** button
   - Fill in required parameters
   - Edit request body if needed

5. **Execute**
   - Click **Execute** button
   - View the response below

6. **Analyze response**
   - Check response code
   - Review response body
   - Examine response headers

---

## Testing with cURL

cURL is a command-line tool for making HTTP requests.

### Basic GET Request

```bash
curl -X GET "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <token>"
```

### GET Request with Query Parameters

```bash
curl -X GET "http://localhost:8080/api/tawatch/products?page=0&size=10&sort=price,desc" \
  -H "Authorization: Bearer <token>"
```

### POST Request

```bash
curl -X POST "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Omega Speedmaster",
    "brand": "Omega",
    "price": 6500.00,
    "category": "LUXURY"
  }'
```

### PUT Request

```bash
curl -X PUT "http://localhost:8080/api/tawatch/products/1" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Omega Speedmaster Professional",
    "brand": "Omega",
    "price": 7000.00,
    "category": "LUXURY"
  }'
```

### DELETE Request

```bash
curl -X DELETE "http://localhost:8080/api/tawatch/products/1" \
  -H "Authorization: Bearer <token>"
```

### Pretty Print JSON Response

Add `| jq` to format JSON output (requires jq to be installed):

```bash
curl -X GET "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <token>" | jq
```

### Save Response to File

```bash
curl -X GET "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <token>" \
  -o response.json
```

---

## Testing with Postman

Postman is a popular GUI tool for API testing.

### Initial Setup

1. **Import OpenAPI Specification**
   - Open Postman
   - Click **File** → **Import**
   - Select **Link** tab
   - Paste: `http://localhost:8080/api/tawatch/v3/api-docs`
   - Click **Import**

2. **Create Environment**
   - Click **Environments** in sidebar
   - Click **+** to create new environment
   - Name it "Tawatch Local"
   - Add variables:
     - `baseUrl`: `http://localhost:8080/api/tawatch`
     - `token`: (leave empty for now)
   - Click **Save**

### Authentication Setup

#### Option 1: Environment Variable

1. **Get a token**
   - Send login request
   - Copy the token from response

2. **Store in environment**
   - Click **Environments**
   - Select "Tawatch Local"
   - Paste token into `token` variable
   - Click **Save**

3. **Use in requests**
   - Go to any request
   - Select **Authorization** tab
   - Type: **Bearer Token**
   - Token: `{{token}}`

#### Option 2: Collection Authorization

1. **Set at collection level**
   - Right-click the imported collection
   - Click **Edit**
   - Go to **Authorization** tab
   - Type: **Bearer Token**
   - Token: `{{token}}`
   - Click **Save**

2. **All requests inherit this setting**

### Making Requests

1. **Select a request** from the imported collection
2. **Review parameters** - Check path variables, query params
3. **Review body** - For POST/PUT requests
4. **Click Send**
5. **Review response** - Status code, body, headers, time

### Organizing Tests

Create folders to organize your requests:
- **Auth** - Login, logout, refresh
- **Products** - Product CRUD operations
- **Orders** - Order management
- **Users** - User management

---

## Testing with HTTPie

HTTPie is a user-friendly command-line HTTP client.

### Installation

```bash
# Linux/macOS
pip install httpie

# Windows
pip install httpie
```

### Usage Examples

**GET request:**
```bash
http GET localhost:8080/api/tawatch/products \
  Authorization:"Bearer <token>"
```

**POST request:**
```bash
echo '{
  "name": "Omega Speedmaster",
  "price": 6500.00,
  "category": "LUXURY"
}' | http POST localhost:8080/api/tawatch/products \
  Authorization:"Bearer <token>"
```

HTTPie automatically:
- Pretty-prints JSON
- Uses syntax highlighting
- Infers request method from data

---

## Rate Limiting

(To be implemented)

Future rate limits:
- **Unauthenticated requests:** 100 requests/hour per IP
- **Authenticated requests:** 1000 requests/hour per user

When rate limited, you'll receive:

```json
{
  "status": "error",
  "message": "Rate limit exceeded",
  "code": "RATE_LIMIT_EXCEEDED",
  "retryAfter": 3600
}
```

---

## Testing Best Practices

1. **Start with Swagger UI** - Great for initial exploration
2. **Use Postman for complex workflows** - Save and organize test scenarios
3. **Use cURL for automation** - Script repetitive tasks
4. **Test error cases** - Don't just test happy paths
5. **Verify response codes** - Ensure correct HTTP status codes
6. **Check response format** - Validate against expected schema
7. **Test authentication** - Verify both authenticated and unauthenticated scenarios

---

## Common Testing Scenarios

### Testing Pagination

```bash
# First page
curl "http://localhost:8080/api/tawatch/products?page=0&size=10"

# Second page
curl "http://localhost:8080/api/tawatch/products?page=1&size=10"

# Verify totalPages matches data
```

### Testing Sorting

```bash
# Sort by price ascending
curl "http://localhost:8080/api/tawatch/products?sort=price,asc"

# Sort by multiple fields
curl "http://localhost:8080/api/tawatch/products?sort=category,asc&sort=price,desc"
```

### Testing Validation

```bash
# Send invalid data
curl -X POST "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "",
    "price": -100
  }'

# Expect 400 Bad Request with validation errors
```

### Testing Authentication

```bash
# Without token - expect 401
curl "http://localhost:8080/api/tawatch/products"

# With invalid token - expect 401
curl "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer invalid-token"

# With valid token - expect 200
curl "http://localhost:8080/api/tawatch/products" \
  -H "Authorization: Bearer <valid-token>"
```

---

## Next Steps

- [Authentication](authentication.md) - Learn about API authentication
- [API Conventions](conventions.md) - Understand API response formats
- [API Overview](overview.md) - Return to API overview