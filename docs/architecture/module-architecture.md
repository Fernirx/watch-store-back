# Module Architecture

This document describes the modular architecture of the Tawatch Backend application, including module organization, layer structure, and component responsibilities.

---

## Table of Contents

- [Overview](#overview)
- [Architecture Pattern](#architecture-pattern)
- [Module Organization](#module-organization)
- [Layer Structure](#layer-structure)
- [Package Structure](#package-structure)
- [Module Details](#module-details)
- [Cross-Cutting Concerns](#cross-cutting-concerns)
- [Module Dependencies](#module-dependencies)
- [Best Practices](#best-practices)

---

## Overview

The Tawatch Backend follows a **modular monolithic architecture** using Spring Boot. The application is organized into logical modules based on business domains, with each module containing all layers needed for its functionality.

**Key Characteristics:**
- **Feature-Based Modular Architecture** - Modules organized by feature/functionality
- **Layered Architecture** - Clear separation of concerns
- **RESTful API** - Standard HTTP/JSON interface
- **Spring Boot Framework** - Dependency injection and auto-configuration
- **JPA/Hibernate** - ORM for database access

---

## Architecture Pattern

### Layered Architecture

The application follows a traditional layered architecture pattern:

```
+------------------------------------------+
|         Presentation Layer               |
|     (Controllers, DTOs, Mappers)         |
+------------------------------------------+
|           Service Layer                  |
|    (Business Logic, Transactions)        |
+------------------------------------------+
|         Persistence Layer                |
|    (Repositories, Entities, JPA)         |
+------------------------------------------+
|            Database Layer                |
|           (MySQL Database)               |
+------------------------------------------+
```

**Layer Responsibilities:**

1. **Presentation Layer**
    - Handle HTTP requests/responses
    - Input validation
    - DTO transformation
    - API documentation (Swagger/OpenAPI)

2. **Service Layer**
    - Business logic implementation
    - Transaction management
    - Domain rules enforcement
    - Orchestration of multiple repositories

3. **Persistence Layer**
    - Database operations (CRUD)
    - Query methods
    - Entity mapping
    - Relationship management

4. **Database Layer**
    - Data storage
    - Constraints enforcement
    - Indexing
    - Transaction support

---

## Module Organization

### Starter Module

**Package:** `vn.fernirx.tawatch.starter`

**Current Implementation:**
- Basic Spring Boot application setup
- Application entry point (`TawatchApplication.java`)
- Configuration files (application.yml, application-local.yaml)

**Purpose:**
This is the foundation module that contains the main Spring Boot application class and basic configuration.

---

## Layer Structure

### Presentation Layer

#### Controllers

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/controller/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/controller/ProductController.java`

**Responsibilities:**
- Define REST endpoints
- Handle HTTP requests
- Validate input (Spring Validation)
- Call service layer methods
- Return DTOs (not entities)
- Handle exceptions (via exception handlers)

**Example Structure:**
```java
@RestController
@RequestMapping("/products")
@RequiredArgsConstructor
@Tag(name = "Products", description = "Product management APIs")
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<SuccessResponse<PageResponse<ProductResponse>>> getAllProducts(Pageable pageable) {
        // Delegate to service layer
        Page<ProductResponse> products = productService.getAllProducts(pageable);
        PageResponse<ProductResponse> pageResponse = new PageResponse<>(products);
        return ResponseEntity.ok(SuccessResponse.of(
            ApiFormatter.resourcesRetrieved("Product"),
            pageResponse
        ));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<SuccessResponse<ProductResponse>> createProduct(
        @Valid @RequestBody ProductRequest request
    ) {
        ProductResponse created = productService.createProduct(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(SuccessResponse.of(
            ApiFormatter.resourceCreated("Product"),
            created
        ));
    }
}
```

**Conventions:**
- Use `@RestController` annotation
- Map to `/{resource}` path (context-path `/api/tawatch` is already configured)
- Return `ResponseEntity<T>` for explicit HTTP status control
- Use DTOs for request/response bodies
- Apply `@PreAuthorize` for authorization
- Use `@Valid` for request validation

#### DTOs (Data Transfer Objects)

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/dto/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/dto/request/ProductRequest.java`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/dto/response/ProductResponse.java`

**Purpose:**
- Decouple API contract from domain model
- Control what data is exposed
- Apply validation rules
- Support versioning

**Types:**

1. **Request DTOs** - Client → Server
   ```java
   @Data
   @NoArgsConstructor
   @AllArgsConstructor
   public class ProductRequest {
       @NotBlank(message = "Product name is required")
       @Size(max = 255)
       private String name;

       @NotNull(message = "Price is required")
       @DecimalMin(value = "0.0", inclusive = false)
       private BigDecimal price;

       @NotNull
       private Long brandId;

       @NotNull
       private Long categoryId;
   }
   ```

2. **Response DTOs** - Server → Client
   ```java
   @Data
   @NoArgsConstructor
   @AllArgsConstructor
   public class ProductResponse {
       private Long id;
       private String code;
       private String name;
       private String slug;
       private BigDecimal price;
       private BigDecimal originalPrice;
       private Integer stockQuantity;
       private BrandResponse brand;
       private List<CategoryResponse> categories;
       private String primaryImageUrl;
       private Boolean isNew;
       private Boolean isOnSale;
       private LocalDateTime createdAt;
   }
   ```

#### Mappers

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/mapper/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/mapper/ProductMapper.java`

**Purpose:**
- Convert between DTOs and Entities
- Apply transformation logic
- Handle nested relationships

**Implementation Options:**

1. **MapStruct** (Recommended)
   ```java
   @Mapper(componentModel = "spring")
   public interface ProductMapper {
       ProductResponse toResponse(Product product);
       Product toEntity(ProductRequest request);
       void updateEntity(ProductRequest request, @MappingTarget Product product);
   }
   ```

2. **Manual Mapping**
   ```java
   @Component
   public class ProductMapper {
       public ProductResponse toResponse(Product product) {
           ProductResponse response = new ProductResponse();
           response.setId(product.getId());
           response.setName(product.getName());
           response.setPrice(product.getPrice());
           // ... map other fields
           return response;
       }
   }
   ```

### Service Layer

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/service/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/service/ProductService.java`

**Responsibilities:**
- Implement business logic
- Manage transactions (`@Transactional`)
- Orchestrate multiple repositories
- Enforce business rules
- Handle domain events
- Perform data validation

**Example Structure:**
```java
@Service
@Transactional
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;
    private final BrandRepository brandRepository;
    private final CategoryRepository categoryRepository;
    private final ProductMapper productMapper;

    public ProductResponse createProduct(ProductRequest request) {
        // Validate business rules
        validateProductCode(request.getCode());

        // Fetch related entities
        Brand brand = brandRepository.findById(request.getBrandId())
            .orElseThrow(() -> new ResourceNotFoundException("Brand not found"));

        // Create entity
        Product product = productMapper.toEntity(request);
        product.setBrand(brand);

        // Save to database
        Product saved = productRepository.save(product);

        // Return DTO
        return productMapper.toResponse(saved);
    }

    @Transactional(readOnly = true)
    public Page<ProductResponse> getAllProducts(Pageable pageable) {
        Page<Product> products = productRepository.findAll(pageable);
        return products.map(productMapper::toResponse);
    }
}
```

**Conventions:**
- Use `@Service` annotation
- Apply `@Transactional` at class level
- Use `@Transactional(readOnly = true)` for read operations
- Throw domain-specific exceptions
- Never expose entities directly
- Validate business rules before persistence

### Persistence Layer

#### Repositories

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/repository/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/repository/ProductRepository.java`

**Purpose:**
- Database access abstraction
- Query methods
- Custom queries
- Specification-based queries

**Example Structure:**
```java
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {

    // Derived query methods
    Optional<Product> findByCode(String code);
    Optional<Product> findBySlug(String slug);
    List<Product> findByBrandIdAndIsActiveTrue(Long brandId);

    // Custom queries
    @Query("SELECT p FROM Product p WHERE p.stockQuantity <= p.minStockLevel")
    List<Product> findLowStockProducts();

    @Query("SELECT p FROM Product p " +
           "JOIN FETCH p.brand " +
           "JOIN FETCH p.categories " +
           "WHERE p.id = :id")
    Optional<Product> findByIdWithDetails(@Param("id") Long id);

    // Native query
    @Query(value = "SELECT * FROM products p WHERE MATCH(p.name, p.description) AGAINST (?1 IN NATURAL LANGUAGE MODE)",
           nativeQuery = true)
    List<Product> fullTextSearch(String searchTerm);

    // Specifications
    Page<Product> findAll(Specification<Product> spec, Pageable pageable);
}
```

**Conventions:**
- Extend `JpaRepository<Entity, ID>`
- Use `@Repository` annotation
- Use derived query methods when possible
- Use `@Query` for complex queries
- Use `JOIN FETCH` to avoid N+1 problems
- Use `Specification` for dynamic queries

#### Entities

**Location:** `tawatch-{feature}/src/main/java/vn/fernirx/tawatch/{feature}/entity/`

**Example:** `tawatch-product/src/main/java/vn/fernirx/tawatch/product/entity/Product.java`

**Purpose:**
- Represent database tables
- Define relationships
- Apply JPA annotations
- Implement domain logic

**Example Structure:**
```java
@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_products_name", columnList = "name"),
    @Index(name = "idx_products_brand_active", columnList = "brand_id, is_active")
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", unique = true, nullable = false, length = 50)
    private String code;

    @Column(name = "name", nullable = false, length = 255)
    private String name;

    @Column(name = "slug", unique = true, nullable = false, length = 255)
    private String slug;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "price", nullable = false, precision = 15, scale = 2)
    private BigDecimal price;

    @Column(name = "original_price", precision = 15, scale = 2)
    private BigDecimal originalPrice;

    @Column(name = "stock_quantity", nullable = false)
    private Integer stockQuantity = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "brand_id", nullable = false)
    private Brand brand;

    @ManyToMany
    @JoinTable(
        name = "product_categories",
        joinColumns = @JoinColumn(name = "product_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    private List<Category> categories = new ArrayList<>();

    @OneToMany(mappedBy = "product", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProductImage> images = new ArrayList<>();

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    // Business logic methods
    public boolean isInStock() {
        return stockQuantity != null && stockQuantity > 0;
    }

    public boolean needsReorder() {
        return stockQuantity <= reorderPoint;
    }

    public void reduceStock(int quantity) {
        if (quantity > stockQuantity) {
            throw new InsufficientStockException("Not enough stock");
        }
        this.stockQuantity -= quantity;
    }
}
```

**Conventions:**
- Use `@Entity` and `@Table` annotations
- Extend `BaseEntity` for common fields (createdAt, updatedAt)
- Use `@Data` (Lombok) for getters/setters
- Use `FetchType.LAZY` for associations
- Apply proper cascade and orphan removal
- Implement business methods in entities
- Use proper column definitions

---

## Package Structure

```
tawatch-backend/
├── tawatch-starter/          # Main Spring Boot starter module
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/         # Application source code
│   │   │   └── resources/    # Configuration files
│   │   └── test/             # Test source code
│   ├── pom.xml               # Module dependencies
│   └── README.md             # Module documentation
├── docs/
│   ├───api
│   ├───architecture
│   ├───development
│   └───setup
├── bin/                      # Helper scripts
│   ├── linux/                # Linux/macOS scripts
│   └── win/                  # Windows scripts
├── README.md                 # Project overview
├── Dockerfile                # Docker image configuration
├── docker-compose.yml        # Docker Compose orchestration
├── .env.example              # Environment variables template
├── .gitignore                # Git ignore rules
├── .dockerignore             # Docker ignore rules
└── pom.xml                   # Root Maven POM
```

---

## Module Details

### Starter Module

**Package:** `vn.fernirx.tawatch.starter`

**Architectural Role:**
The Starter Module is the **bootstrap entry point** of the modular monolith architecture. It has no business domain of its own, but instead:
- Bootstraps the Spring Boot application context via `@SpringBootApplication`
- Triggers component scanning to discover beans from all modules
- Manages environment-specific configuration (application-{profile}.yml)
- Serves as the executable JAR entry point

**Position in Architecture:**

```
┌─────────────────────────────────────────────┐
│    Starter Module (Bootstrap Entry Point)   │
│                                             │
│  @SpringBootApplication                     │
│  └─ Enables component scanning              │
│  └─ Auto-configuration                      │
│                                             │
└─────────────────────────────────────────────┘
                      │
        Component Scanning discovers beans from:
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
  ┌─────────┐   ┌─────────┐   ┌─────────────────┐
  │ Feature │   │ Feature │   │ infrastructure  │
  │ Module  │   │ Module  │   │     Module      │
  │    A    │   │    B    │   │                 │
  └─────────┘   └─────────┘   └─────────────────┘
```

**Key Architectural Characteristics:**

1. **Ultra-Thin Bootstrap** - Contains ONLY @SpringBootApplication + main() method
2. **No Bean Definitions** - No @Configuration, @Bean, or implementation code
3. **Component Scanning Hub** - Discovers and wires beans from feature/common modules
4. **Configuration Orchestrator** - Manages profile-based application.yml files

**Interaction with Feature Modules:**

- Feature modules are **independent** of the starter module at compile time
- The starter module **discovers** feature modules at runtime via component scanning
- Each feature module contributes its own controllers, services, and repositories
- The starter module aggregates all endpoints into a single API surface

**What Belongs Here:**
- ✅ Application entry point (`@SpringBootApplication`)
- ✅ Profile configuration and environment switching
- ✅ Cross-cutting infrastructure setup (Swagger, Actuator)
- ✅ Database migration orchestration (Flyway/Liquibase)

**What Does NOT Belong Here:**
- ❌ Domain entities or business logic
- ❌ Feature-specific controllers or services
- ❌ Business validation rules
- ❌ Feature-specific dependencies

> **Implementation Details:** For file structure, dependencies, profiles, and setup instructions, see [tawatch-starter/README.md](../../tawatch-starter/README.md)

---

## Cross-Cutting Concerns

### Security

**Implementation:**
- Spring Security
- JWT for stateless authentication
- Role-based access control (`@PreAuthorize`)
- CORS configuration
- CSRF protection (disabled for stateless API)

**Key Classes:**
- `SecurityConfig` - Security configuration
- `JwtTokenProvider` - JWT operations
- `JwtAuthenticationFilter` - JWT validation filter
- `UserDetailsServiceImpl` - User loading

### Exception Handling

**Implementation:**
- Global exception handler (`@ControllerAdvice`)
- Custom exception hierarchy
- Standardized error responses

**Example:**
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
                "NOT_FOUND",
                ex.getMessage(),
                HttpStatus.NOT_FOUND.value()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationError(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );

        ErrorResponse error = new ErrorResponse(
                "VALIDATION_ERROR",
                "Validation failed",
                HttpStatus.BAD_REQUEST.value(),
                errors
        );
        return ResponseEntity.badRequest().body(error);
    }
}
```

### Validation

**Implementation:**
- Jakarta Bean Validation
- Custom validators
- Service-level validation

**Example:**
```java
// DTO validation
@Data
public class ProductRequest {
    @NotBlank(message = "Name is required")
    @Size(min = 3, max = 255)
    private String name;

    @NotNull
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal price;

    @Email
    private String contactEmail;
}

// Custom validator
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = ValidPhoneNumberValidator.class)
public @interface ValidPhoneNumber {
    String message() default "Invalid Vietnamese phone number";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};
}
```

### Transaction Management

**Implementation:**
- `@Transactional` annotation
- Declarative transaction boundaries
- Read-only optimization

**Best Practices:**
```java
@Service
@Transactional
public class OrderService {

    // Write operations - use default transaction
    public OrderResponse createOrder(OrderRequest request) {
        // Transaction automatically managed
        Order order = orderRepository.save(order);
        inventoryService.reduceStock(order.getItems());
        return mapper.toResponse(order);
    }

    // Read operations - use read-only for optimization
    @Transactional(readOnly = true)
    public OrderResponse getOrder(Long id) {
        return orderRepository.findById(id)
                .map(mapper::toResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
    }
}
```

### Logging

**Implementation:**
- SLF4J with Logback
- Structured logging
- Different log levels per environment

**Example:**
```java
@Slf4j
@Service
public class ProductService {

    public ProductResponse createProduct(ProductRequest request) {
        log.info("Creating product: {}", request.getName());

        try {
            Product product = productRepository.save(product);
            log.info("Product created successfully: id={}, code={}",
                    product.getId(), product.getCode());
            return mapper.toResponse(product);
        } catch (Exception e) {
            log.error("Failed to create product: {}", request.getName(), e);
            throw new ProductCreationException("Failed to create product", e);
        }
    }
}
```

### API Documentation

**Implementation:**
- SpringDoc OpenAPI 3
- Swagger UI
- Annotations for documentation

**Example:**
```java
@RestController
@RequestMapping("/products")
@Tag(name = "Products", description = "Product management APIs")
public class ProductController {

    @Operation(
            summary = "Get all products",
            description = "Returns a paginated list of products"
    )
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Success"),
            @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping
    public ResponseEntity<SuccessResponse<PageResponse<ProductResponse>>> getAllProducts(
            @Parameter(description = "Pagination parameters")
            Pageable pageable
    ) {
        // Implementation
    }
}
```

---

## Module Dependencies

### Dependency Rules

1. **Presentation → Service → Persistence**
    - Controllers depend on Services
    - Services depend on Repositories
    - Never skip layers

2. **No Circular Dependencies**
    - Modules should not have circular dependencies
    - Use events or interfaces to decouple

### Module Interaction

```
+---------------------------------------------+
|              Presentation Layer             |
|  +----------+  +----------+  +----------+   |
|  |  Auth    |  | Product  |  |  Order   |   |
|  |Controller|  |Controller|  |Controller|   |
|  +----+-----+  +----+-----+  +----+-----+   |
+-------+-------------+---------------+-------+
        |             |               |
+-------+-------------+---------------+-------+
|       |   Service Layer             |       |
|  +----v-----+  +----v-----+  +-----v----+   |
|  |  Auth    |  | Product  |  |  Order   |   |
|  | Service  |  | Service  |  | Service  |   |
|  +----+-----+  +----+-----+  +----+-----+   |
+-------+-------------+---------------+-------+
        |             |               |
+-------+-------------+---------------+-------+
|       |  Persistence Layer          |       |
|  +----v-----+  +----v-----+  +-----v----+   |
|  |   User   |  | Product  |  |  Order   |   |
|  |Repository|  |Repository|  |Repository|   |
|  +----------+  +----------+  +----------+   |
+---------------------------------------------+
```

---

## Best Practices

### 1. Code Organization

✅ **Do:**
- Organize by feature
- Keep related code together
- Use meaningful package names
- Follow consistent naming conventions

❌ **Don't:**
- Mix presentation and business logic
- Create god classes
- Use generic names like `Manager` or `Helper`

### 2. Layer Separation

✅ **Do:**
- Keep layers independent
- Use DTOs for API contracts
- Return DTOs from controllers
- Use entities only in service and repository layers

❌ **Don't:**
- Expose entities in API responses
- Put business logic in controllers
- Access repositories from controllers
- Skip the service layer

### 3. Transaction Management

✅ **Do:**
- Use `@Transactional` at service level
- Use `readOnly=true` for read operations
- Keep transactions short
- Handle exceptions properly

❌ **Don't:**
- Use transactions in controllers
- Mix read and write in read-only transactions
- Catch and swallow transaction exceptions

### 4. Error Handling

✅ **Do:**
- Use specific exception types
- Provide meaningful error messages
- Return consistent error format
- Log errors appropriately

❌ **Don't:**
- Return stack traces to clients
- Use generic Exception
- Suppress exceptions without logging
- Return different error formats

### 5. Testing

✅ **Do:**
- Write unit tests for services
- Write integration tests for repositories
- Use test fixtures
- Mock external dependencies

❌ **Don't:**
- Test framework code
- Write tests that depend on database state
- Skip edge cases

### 6. Performance

✅ **Do:**
- Use pagination for large result sets
- Use `@Lazy` loading for associations
- Use `JOIN FETCH` to avoid N+1
- Add appropriate indexes
- Cache frequently accessed data

❌ **Don't:**
- Load entire collections unnecessarily
- Use `@Eager` loading by default
- Ignore query performance
- Over-cache mutable data

### 7. Security

✅ **Do:**
- Validate all inputs
- Use parameterized queries
- Apply principle of least privilege
- Log security events
- Hash passwords properly (BCrypt)

❌ **Don't:**
- Trust client input
- Build queries with string concatenation
- Store sensitive data in logs
- Use weak hashing algorithms

---

## Next Steps

- [Database Schema](database-schema.md) - Database structure and relationships
- [API Overview](../api/overview.md) - RESTful API documentation
- [Authentication](../api/authentication.md) - Authentication and authorization
- [Configuration Guide](../setup/configuration.md) - Application configuration
- [Development Guide](../development/development-guide.md) - Development environment setup

---