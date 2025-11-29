# Database Schema

This document provides a comprehensive overview of the Tawatch Backend database schema, including table structures, relationships, and design decisions.

---

## Overview

The Tawatch database (`tawatch_db`) is designed to support a complete e-commerce platform for watch retail. It uses MySQL with UTF-8 encoding (`utf8mb4_unicode_520_ci`) and follows a normalized relational design pattern.

**Database Name:** `tawatch_db`
**Character Set:** `utf8mb4`
**Collation:** `utf8mb4_unicode_520_ci`
**Engine:** InnoDB (all tables)

---

## Database Structure

The schema is organized into six logical modules:

1. **Core & Authentication** - User accounts, authentication, and authorization
2. **Product Catalog** - Products, categories, brands, and specifications
3. **Inventory & Supplier Management** - Stock control, suppliers, and purchase orders
4. **Order & Shopping** - Cart, orders, payments, and coupons
5. **User Engagement & Content** - Reviews, wishlists, notifications, and FAQs
6. **System & Audit** - Activity logs and system tracking

---

## Core & Authentication Tables

### `users`

**Purpose:** Manages user accounts, authentication, and authorization.

| Field            | Type            | Description                                  |
|------------------|-----------------|----------------------------------------------|
| `id`             | BIGINT UNSIGNED | Unique user ID (primary key)                 |
| `email`          | VARCHAR(100)    | Login email (unique)                         |
| `password_hash`  | VARCHAR(255)    | Hashed password (NULL for OAuth)             |
| `provider`       | ENUM            | Authentication method: `LOCAL`, `GOOGLE`     |
| `provider_id`    | VARCHAR(255)    | OAuth provider ID (Google sub claim)         |
| `role`           | ENUM            | User role: `USER`, `STAFF`, `ADMIN` |
| `is_verified`    | BOOLEAN         | Email verification status                    |
| `is_active`      | BOOLEAN         | Account active status                        |
| `login_attempts` | TINYINT         | Failed login counter                         |
| `locked_until`   | DATETIME        | Account unlock timestamp                     |
| `last_login`     | DATETIME        | Last successful login                        |
| `created_at`     | DATETIME        | Account creation timestamp                   |
| `updated_at`     | DATETIME        | Last update timestamp                        |

**Key Indexes:**
- `email_UNIQUE` (`email`) - Ensures email uniqueness
- `idx_users_provider` (`provider`, `provider_id`) - Fast OAuth lookup
- `idx_users_role_active` (`role`, `is_active`) - Role-based queries

**Authentication Flow:**
- Supports both local (email/password) and OAuth2 (Google) authentication
- Failed login attempts trigger temporary account locks
- Password hash stored using bcrypt (for LOCAL provider)

### `user_profiles`

**Purpose:** Stores detailed personal information for users (1-to-1 relationship with `users`).

| Field           | Type            | Description                      |
|-----------------|-----------------|----------------------------------|
| `id`            | BIGINT UNSIGNED | Profile ID (primary key)         |
| `user_id`       | BIGINT UNSIGNED | Reference to `users.id` (unique) |
| `first_name`    | VARCHAR(100)    | User's first name                |
| `last_name`     | VARCHAR(100)    | User's last name                 |
| `phone`         | VARCHAR(15)     | Vietnamese phone number          |
| `avatar_url`    | VARCHAR(500)    | Profile picture URL              |
| `date_of_birth` | DATE            | Date of birth                    |
| `created_at`    | DATETIME        | Profile creation timestamp       |
| `updated_at`    | DATETIME        | Last update timestamp            |

**Constraints:**
- UNIQUE `user_id_UNIQUE` (`user_id`) - One profile per user

**Key Indexes:**
- `idx_profiles_name` (`last_name`, `first_name`) - Name search
- `idx_profiles_phone` (`phone`) - Phone lookup

**Relationship:** CASCADE delete when user is deleted.

### `addresses`

**Purpose:** Multi-address support for user shipping addresses.

| Field            | Type            | Description                |
|------------------|-----------------|----------------------------|
| `id`             | BIGINT UNSIGNED | Address ID (primary key)   |
| `user_id`        | BIGINT UNSIGNED | Reference to `users.id`    |
| `recipient_name` | VARCHAR(200)    | Recipient's full name      |
| `phone`          | VARCHAR(15)     | Contact phone number       |
| `street`         | VARCHAR(255)    | Street address             |
| `ward`           | VARCHAR(100)    | Ward/commune               |
| `city`           | VARCHAR(100)    | City/province              |
| `postal_code`    | VARCHAR(6)      | Postal code (6 digits)     |
| `country`        | VARCHAR(100)    | Country (default: Vietnam) |
| `is_default`     | BOOLEAN         | Default address flag       |
| `created_at`     | DATETIME        | Address creation timestamp |
| `updated_at`     | DATETIME        | Last update timestamp      |

**Key Indexes:**
- `idx_addresses_user_default` (`user_id`, `is_default`) - Fast default address lookup
- `idx_addresses_recipient_name` (`recipient_name`) - Name search

**Features:**
- Users can have multiple addresses
- One address can be marked as default
- Vietnamese address format (street, ward, city)

### `guest_sessions`

**Purpose:** Enables guest checkout without user registration.

| Field         | Type            | Description                      |
|---------------|-----------------|----------------------------------|
| `id`          | BIGINT UNSIGNED | Session ID (primary key)         |
| `guest_token` | VARCHAR(64)     | Unique guest identifier (unique) |
| `created_at`  | DATETIME        | Session creation time            |
| `last_active` | DATETIME        | Last activity timestamp          |
| `expires_at`  | DATETIME        | Session expiration time          |

**Constraints:**
- UNIQUE `guest_token_UNIQUE` (`guest_token`) - One session per token

**Key Indexes:**
- `idx_guest_sessions_expires` (`expires_at`) - Cleanup expired sessions

**Lifecycle:** Sessions expire after 30 days of inactivity. Cart data is linked to guest tokens.

### `token_blacklist`

**Purpose:** Invalidates JWT tokens after logout or revocation.

| Field        | Type            | Description                            |
|--------------|-----------------|----------------------------------------|
| `id`         | BIGINT UNSIGNED | Blacklist entry ID                     |
| `user_id`    | BIGINT UNSIGNED | Token owner (nullable)                 |
| `token`      | VARCHAR(512)    | Blacklisted JWT token                  |
| `reason`     | ENUM            | Reason: `LOGOUT`, `REVOKED`, `EXPIRED` |
| `expires_at` | DATETIME        | Token expiration (for cleanup)         |
| `created_at` | DATETIME        | Blacklist timestamp                    |

**Key Indexes:**
- `idx_blacklist_user` (`user_id`) - User token lookup
- `idx_blacklist_token` (`token`(255)) - Token verification (prefix index)

**Security:** Prevents token reuse after logout. Tokens are automatically cleaned after expiration.

---

## Product Catalog Tables

### `categories`

**Purpose:** Hierarchical product categorization with parent-child relationships.

| Field           | Type            | Description                         |
|-----------------|-----------------|-------------------------------------|
| `id`            | BIGINT UNSIGNED | Category ID (primary key)           |
| `parent_id`     | BIGINT UNSIGNED | Parent category ID (self-reference) |
| `name`          | VARCHAR(100)    | Category name (unique)              |
| `slug`          | VARCHAR(100)    | URL-friendly name (unique)          |
| `description`   | TEXT            | Category description                |
| `display_order` | INT             | Display order (lower first)         |
| `is_active`     | BOOLEAN         | Visibility status                   |
| `created_at`    | DATETIME        | Category creation timestamp         |
| `updated_at`    | DATETIME        | Last update timestamp               |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique category names
- UNIQUE `slug_UNIQUE` (`slug`) - Unique slugs

**Key Indexes:**
- `idx_categories_parent_active` (`parent_id`, `is_active`) - Active subcategories

**Features:**
- Supports multi-level hierarchy (parent_id references self)
- NULL parent_id indicates root category
- Slug for SEO-friendly URLs

### `brands`

**Purpose:** Watch brand information.

| Field         | Type            | Description                |
|---------------|-----------------|----------------------------|
| `id`          | BIGINT UNSIGNED | Brand ID (primary key)     |
| `name`        | VARCHAR(100)    | Brand name (unique)        |
| `slug`        | VARCHAR(100)    | URL-friendly name (unique) |
| `description` | TEXT            | Brand description          |
| `logo_url`    | VARCHAR(500)    | Brand logo URL             |
| `is_active`   | BOOLEAN         | Active status              |
| `created_at`  | DATETIME        | Brand creation timestamp   |
| `updated_at`  | DATETIME        | Last update timestamp      |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique brand names
- UNIQUE `slug_UNIQUE` (`slug`) - Unique slugs

**Key Indexes:**
- `idx_brands_active` (`is_active`) - Active brands

### `movements`

**Purpose:** Watch movement types (the watch mechanism).

| Field         | Type            | Description                                    |
|---------------|-----------------|------------------------------------------------|
| `id`          | BIGINT UNSIGNED | Movement ID (primary key)                      |
| `type`        | ENUM            | Type: `Quartz`, `Automatic`, `Manual`, `Solar` |
| `name`        | VARCHAR(100)    | Specific model (e.g., Miyota 2035)             |
| `description` | TEXT            | Technical details                              |
| `created_at`  | DATETIME        | Movement creation timestamp                    |
| `updated_at`  | DATETIME        | Last update timestamp                          |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique movement names

**Key Indexes:**
- `idx_movements_type` (`type`) - Movement type lookup

**Movement Types:**
- **Quartz** - Battery-powered, high accuracy
- **Automatic** - Self-winding mechanical
- **Manual** - Hand-wound mechanical
- **Solar** - Solar-powered

### `materials`

**Purpose:** Materials used in watch components.

| Field         | Type            | Description                         |
|---------------|-----------------|-------------------------------------|
| `id`          | BIGINT UNSIGNED | Material ID (primary key)           |
| `type`        | ENUM            | Component: `STRAP`, `GLASS`, `CASE` |
| `name`        | VARCHAR(100)    | Material name (unique)              |
| `description` | TEXT            | Material properties                 |
| `created_at`  | DATETIME        | Material creation timestamp         |
| `updated_at`  | DATETIME        | Last update timestamp               |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique material names

**Key Indexes:**
- `idx_materials_type` (`type`) - Material type lookup

**Material Types:**
- **STRAP** - Watch band materials (leather, steel, rubber, fabric)
- **GLASS** - Crystal materials (sapphire, mineral, acrylic)
- **CASE** - Case materials (stainless steel, titanium, plastic)

### `colors`

**Purpose:** Product color options.

| Field        | Type            | Description                    |
|--------------|-----------------|--------------------------------|
| `id`         | BIGINT UNSIGNED | Color ID (primary key)         |
| `name`       | VARCHAR(50)     | Color name (unique)            |
| `hex_code`   | VARCHAR(7)      | Hex color code (e.g., #000000) |
| `created_at` | DATETIME        | Color creation timestamp       |
| `updated_at` | DATETIME        | Last update timestamp          |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique color names

### `water_resistances`

**Purpose:** Water resistance levels.

| Field        | Type            | Description                               |
|--------------|-----------------|-------------------------------------------|
| `id`         | BIGINT UNSIGNED | Water resistance ID (primary key)         |
| `level`      | VARCHAR(50)     | Resistance level (e.g., "3 ATM", "5 ATM") |
| `created_at` | DATETIME        | Creation timestamp                        |
| `updated_at` | DATETIME        | Last update timestamp                     |

**Constraints:**
- UNIQUE `level_UNIQUE` (`level`) - Unique levels

**Common Levels:**
- 3 ATM - Splash resistant (hand washing)
- 5 ATM - Swimming
- 10 ATM - Diving

### `battery_types`

**Purpose:** Battery specifications for quartz watches.

| Field        | Type            | Description                     |
|--------------|-----------------|---------------------------------|
| `id`         | BIGINT UNSIGNED | Battery type ID (primary key)   |
| `name`       | VARCHAR(50)     | Battery model (e.g., SR626SW)   |
| `voltage`    | VARCHAR(20)     | Voltage rating (e.g., 1.5V, 3V) |
| `created_at` | DATETIME        | Creation timestamp              |
| `updated_at` | DATETIME        | Last update timestamp           |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique battery types

### `features`

**Purpose:** Special watch features and functions.

| Field         | Type            | Description              |
|---------------|-----------------|--------------------------|
| `id`          | BIGINT UNSIGNED | Feature ID (primary key) |
| `name`        | VARCHAR(100)    | Feature name (unique)    |
| `description` | TEXT            | Feature description      |
| `created_at`  | DATETIME        | Creation timestamp       |
| `updated_at`  | DATETIME        | Last update timestamp    |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique feature names

**Examples:** Chronograph, Date Display, GMT, Alarm, Tachymeter

### `products`

**Purpose:** Main product table with detailed specifications.

| Field                 | Type            | Description                      |
|-----------------------|-----------------|----------------------------------|
| `id`                  | BIGINT UNSIGNED | Product ID (primary key)         |
| `brand_id`            | BIGINT UNSIGNED | Brand reference                  |
| `movement_id`         | BIGINT UNSIGNED | Movement reference               |
| `case_material_id`    | BIGINT UNSIGNED | Case material reference          |
| `strap_material_id`   | BIGINT UNSIGNED | Strap material reference         |
| `glass_material_id`   | BIGINT UNSIGNED | Glass material reference         |
| `water_resistance_id` | BIGINT UNSIGNED | Water resistance reference       |
| `battery_type_id`     | BIGINT UNSIGNED | Battery type (Quartz only)       |
| `color_id`            | BIGINT UNSIGNED | Primary color reference          |
| `code`                | VARCHAR(50)     | Product code (unique)            |
| `name`                | VARCHAR(255)    | Product name                     |
| `slug`                | VARCHAR(255)    | URL-friendly name (unique)       |
| `description`         | TEXT            | HTML product description         |
| `price`               | DECIMAL(15,2)   | Current selling price (VNĐ)      |
| `original_price`      | DECIMAL(15,2)   | Original price before discount   |
| `cost_price`          | DECIMAL(15,2)   | Cost of goods sold (admin only)  |
| `stock_quantity`      | INT             | Current stock level              |
| `min_stock_level`     | INT             | Minimum stock threshold          |
| `reorder_point`       | INT             | Reorder alert threshold          |
| `warranty_period`     | VARCHAR(50)     | Warranty duration                |
| `origin_country`      | VARCHAR(100)    | Manufacturing country            |
| `case_size`           | DECIMAL(6,2)    | Case diameter (mm)               |
| `thickness`           | DECIMAL(6,2)    | Watch thickness (mm)             |
| `weight`              | DECIMAL(6,2)    | Weight (grams)                   |
| `power_reserve`       | VARCHAR(50)     | Power reserve (Automatic/Manual) |
| `is_new`              | BOOLEAN         | "NEW" badge flag                 |
| `is_on_sale`          | BOOLEAN         | "SALE" badge flag                |
| `is_active`           | BOOLEAN         | Product visibility               |
| `sold_count`          | INT             | Total units sold                 |
| `view_count`          | INT             | Product page views               |
| `created_at`          | DATETIME        | Product creation timestamp       |
| `updated_at`          | DATETIME        | Last update timestamp            |

**Constraints:**
- UNIQUE `code_UNIQUE` (`code`) - Unique product codes
- UNIQUE `slug_UNIQUE` (`slug`) - Unique slugs

**Key Indexes:**
- `idx_products_name` (`name`) - Product name search
- `idx_products_brand_active` (`brand_id`, `is_active`) - Active products by brand
- `idx_products_price_stock` (`price`, `stock_quantity`) - Price and stock queries
- `idx_products_new_sale` (`is_new`, `is_on_sale`) - Badge filters
- `idx_products_movement` (`movement_id`) - Movement lookup
- `idx_products_case_material` (`case_material_id`) - Case material lookup
- `idx_products_strap_material` (`strap_material_id`) - Strap material lookup
- `idx_products_glass_material` (`glass_material_id`) - Glass material lookup
- `idx_products_water_resistance` (`water_resistance_id`) - Water resistance lookup
- `idx_products_battery_type` (`battery_type_id`) - Battery type lookup
- `idx_products_color` (`color_id`) - Color lookup

**Key Features:**
- Price tracking: cost_price, original_price, selling price
- Inventory management: stock_quantity, min_stock_level, reorder_point
- Analytics: sold_count, view_count
- SEO: slug for clean URLs

**Foreign Key Constraints:**
- `brand_id` - RESTRICT (cannot delete brand with products)
- `movement_id` - SET NULL (preserve product if movement deleted)
- `case_material_id` - SET NULL (preserve product if material deleted)
- `strap_material_id` - SET NULL (preserve product if material deleted)
- `glass_material_id` - SET NULL (preserve product if material deleted)
- `water_resistance_id` - SET NULL (preserve product if water resistance deleted)
- `battery_type_id` - SET NULL (preserve product if battery type deleted)
- `color_id` - SET NULL (preserve product if color deleted)

### `product_categories`

**Purpose:** Many-to-many relationship between products and categories.

| Field         | Type            | Description             |
|---------------|-----------------|-------------------------|
| `id`          | BIGINT UNSIGNED | Record ID (primary key) |
| `product_id`  | BIGINT UNSIGNED | Product reference       |
| `category_id` | BIGINT UNSIGNED | Category reference      |
| `created_at`  | DATETIME        | Creation timestamp      |
| `updated_at`  | DATETIME        | Last update timestamp   |

**Constraints:**
- UNIQUE `product_category_UNIQUE` (`product_id`, `category_id`) - Prevents duplicates

**Key Indexes:**
- `idx_product_categories_product` (`product_id`) - Product lookup
- `idx_product_categories_category` (`category_id`) - Category lookup

### `product_features`

**Purpose:** Many-to-many relationship between products and features.

| Field        | Type            | Description             |
|--------------|-----------------|-------------------------|
| `id`         | BIGINT UNSIGNED | Record ID (primary key) |
| `product_id` | BIGINT UNSIGNED | Product reference       |
| `feature_id` | BIGINT UNSIGNED | Feature reference       |
| `created_at` | DATETIME        | Creation timestamp      |
| `updated_at` | DATETIME        | Last update timestamp   |

**Constraints:**
- UNIQUE `product_feature_UNIQUE` (`product_id`, `feature_id`) - Prevents duplicates

**Key Indexes:**
- `idx_product_features_product` (`product_id`) - Product lookup
- `idx_product_features_feature` (`feature_id`) - Feature lookup

### `product_images`

**Purpose:** Multiple images per product.

| Field        | Type            | Description            |
|--------------|-----------------|------------------------|
| `id`         | BIGINT UNSIGNED | Image ID (primary key) |
| `product_id` | BIGINT UNSIGNED | Product reference      |
| `image_url`  | VARCHAR(500)    | Image URL              |
| `is_primary` | BOOLEAN         | Primary image flag     |
| `created_at` | DATETIME        | Creation timestamp     |
| `updated_at` | DATETIME        | Last update timestamp  |

**Key Indexes:**
- `idx_product_images_product_primary` (`product_id`, `is_primary`) - Fast primary image lookup

**Features:**
- One image marked as primary (main product image)
- Support for image galleries

---

## Inventory & Supplier Management

### `suppliers`

**Purpose:** Supplier contact and information management.

| Field            | Type            | Description               |
|------------------|-----------------|---------------------------|
| `id`             | BIGINT UNSIGNED | Supplier ID (primary key) |
| `name`           | VARCHAR(200)    | Supplier name (unique)    |
| `code`           | VARCHAR(50)     | Supplier code (unique)    |
| `email`          | VARCHAR(100)    | Contact email             |
| `phone`          | VARCHAR(20)     | Contact phone             |
| `contact_person` | VARCHAR(100)    | Contact person name       |
| `address`        | TEXT            | Full address              |
| `is_active`      | BOOLEAN         | Active status             |
| `notes`          | TEXT            | Additional notes          |
| `created_at`     | DATETIME        | Creation timestamp        |
| `updated_at`     | DATETIME        | Last update timestamp     |

**Constraints:**
- UNIQUE `name_UNIQUE` (`name`) - Unique supplier names
- UNIQUE `code_UNIQUE` (`code`) - Unique supplier codes

**Key Indexes:**
- `idx_is_active` (`is_active`) - Active suppliers

### `purchases`

**Purpose:** Purchase orders from suppliers.

| Field                 | Type            | Description                                                 |
|-----------------------|-----------------|-------------------------------------------------------------|
| `id`                  | BIGINT UNSIGNED | Purchase ID (primary key)                                   |
| `supplier_id`         | BIGINT UNSIGNED | Supplier reference                                          |
| `created_by`          | BIGINT UNSIGNED | Staff who created (STAFF/ADMIN)                             |
| `received_by`         | BIGINT UNSIGNED | Staff who received (STAFF/ADMIN)                            |
| `purchase_code`       | VARCHAR(50)     | Purchase order code (unique)                                |
| `supplier_invoice_no` | VARCHAR(100)    | Supplier's invoice number                                   |
| `order_date`          | DATE            | Purchase order date                                         |
| `subtotal`            | DECIMAL(15,2)   | Total product cost                                          |
| `discount_amount`     | DECIMAL(15,2)   | Supplier discount                                           |
| `tax_amount`          | DECIMAL(15,2)   | VAT amount                                                  |
| `shipping_cost`       | DECIMAL(15,2)   | Shipping fees                                               |
| `total_cost`          | DECIMAL(15,2)   | Final total cost                                            |
| `payment_status`      | ENUM            | Status: `PENDING`, `PAID`                                   |
| `status`              | ENUM            | Order status: `DRAFT`, `RECEIVED`, `COMPLETED`, `CANCELLED` |
| `notes`               | TEXT            | General notes                                               |
| `issues`              | TEXT            | Quality issues found                                        |
| `created_at`          | DATETIME        | Purchase creation timestamp                                 |
| `received_at`         | DATETIME        | Goods received timestamp                                    |
| `updated_at`          | DATETIME        | Last update timestamp                                       |

**Constraints:**
- UNIQUE `purchase_code_UNIQUE` (`purchase_code`) - Unique purchase codes

**Key Indexes:**
- `idx_purchases_supplier` (`supplier_id`) - Supplier lookup
- `idx_purchases_status` (`status`) - Status filtering
- `idx_purchases_payment_status` (`payment_status`) - Payment status filtering

**Purchase Flow:**
1. DRAFT - Order created, not confirmed
2. RECEIVED - Goods physically received
3. COMPLETED - Checked and added to inventory
4. CANCELLED - Order cancelled

### `purchase_items`

**Purpose:** Line items in purchase orders.

| Field               | Type            | Description                                                                        |
|---------------------|-----------------|------------------------------------------------------------------------------------|
| `id`                | BIGINT UNSIGNED | Purchase item ID (primary key)                                                     |
| `purchase_id`       | BIGINT UNSIGNED | Purchase order reference                                                           |
| `product_id`        | BIGINT UNSIGNED | Product reference                                                                  |
| `quantity_ordered`  | INT             | Quantity ordered                                                                   |
| `quantity_received` | INT             | Actual quantity received                                                           |
| `unit_cost`         | DECIMAL(15,2)   | Cost per unit (COGS)                                                               |
| `line_total`        | DECIMAL(15,2)   | Line total cost                                                                    |
| `quality_status`    | ENUM            | Status: `PENDING`, `CHECKED`, `OK`, `DEFECTIVE`, `PARTIALLY_DEFECTIVE`, `RETURNED` |
| `defective_qty`     | INT             | Number of defective units                                                          |
| `defect_reason`     | TEXT            | Defect description                                                                 |
| `is_received`       | BOOLEAN         | Inventory updated flag (true when stock added)                                     |
| `received_date`     | DATETIME        | Inventory add date                                                                 |
| `notes`             | TEXT            | Line item notes                                                                    |
| `created_at`        | DATETIME        | Creation timestamp                                                                 |
| `updated_at`        | DATETIME        | Last update timestamp                                                              |

**Key Indexes:**
- `idx_purchase_items_purchase` (`purchase_id`) - Purchase lookup
- `idx_purchase_items_product` (`product_id`) - Product lookup
- `idx_purchase_items_quality_status` (`quality_status`) - Quality status filtering
- `idx_purchase_items_is_received` (`is_received`) - Received status filtering

**Quality Status Values:**
- `PENDING` - Chưa kiểm tra
- `CHECKED` - Đã kiểm tra
- `OK` - Đạt tiêu chuẩn
- `DEFECTIVE` - Lỗi toàn bộ
- `PARTIALLY_DEFECTIVE` - Lỗi một phần
- `RETURNED` - Trả lại supplier

**Quality Control:**
- Track defective items separately
- Document defect reasons
- Support partial defects

**Foreign Key Constraints:**
- `purchase_id` - CASCADE delete when purchase deleted
- `product_id` - RESTRICT (preserve purchase history)

### `inventory_transactions`

**Purpose:** Complete audit trail of all stock movements (immutable log).

| Field            | Type            | Description                                                        |
|------------------|-----------------|--------------------------------------------------------------------|
| `id`             | BIGINT UNSIGNED | Transaction ID (primary key)                                       |
| `product_id`     | BIGINT UNSIGNED | Product reference                                                  |
| `created_by`     | BIGINT UNSIGNED | User who made change (NULL = system)                               |
| `type`           | ENUM            | Type: `IN`, `OUT`, `ADJUST`                                        |
| `quantity`       | INT             | Change amount (+ or -)                                             |
| `old_stock`      | INT             | Stock before transaction                                           |
| `new_stock`      | INT             | Stock after transaction                                            |
| `reference_type` | ENUM            | Related to: `ORDER`, `PURCHASE`, `RETURN`, `ADJUSTMENT`, `DAMAGED` |
| `reference_id`   | BIGINT UNSIGNED | Related record ID                                                  |
| `note`           | TEXT            | Transaction notes                                                  |
| `created_at`     | DATETIME        | Transaction timestamp                                              |

**Key Indexes:**
- `idx_inventory_product_date` (`product_id`, `created_at`) - Product transaction history
- `idx_inventory_type` (`type`) - Transaction type filtering
- `idx_inventory_reference` (`reference_type`, `reference_id`) - Reference lookup
- `idx_inventory_created_by` (`created_by`) - User activity tracking

**Transaction Types:**
- **IN** - Stock added (purchases, returns)
- **OUT** - Stock removed (sales, damage)
- **ADJUST** - Manual inventory adjustment

**Foreign Key Constraints:**
- `product_id` - RESTRICT (preserve transaction history)
- `created_by` - SET NULL (preserve transaction if user deleted)

**Important:** Records are immutable (never update/delete, only insert). This ensures complete audit trail.

---

## Order & Shopping Tables

### `carts`

**Purpose:** Shopping cart for both registered users and guests.

| Field         | Type            | Description                         |
|---------------|-----------------|-------------------------------------|
| `id`          | BIGINT UNSIGNED | Cart ID (primary key)               |
| `user_id`     | BIGINT UNSIGNED | User reference (NULL for guest)     |
| `guest_token` | VARCHAR(64)     | Guest session token (NULL for user) |
| `created_at`  | DATETIME        | Cart creation timestamp             |
| `updated_at`  | DATETIME        | Last update timestamp               |

**Constraints:**
- UNIQUE `user_cart_user_UNIQUE` (`user_id`) - One cart per user
- UNIQUE `user_cart_guest_UNIQUE` (`guest_token`) - One cart per guest token
- CHECK `chk_cart_user_or_guest` - Either user_id OR guest_token must be set (not both, not neither)

### `cart_items`

**Purpose:** Items in shopping cart.

| Field        | Type            | Description                |
|--------------|-----------------|----------------------------|
| `id`         | BIGINT UNSIGNED | Cart item ID (primary key) |
| `cart_id`    | BIGINT UNSIGNED | Cart reference             |
| `product_id` | BIGINT UNSIGNED | Product reference          |
| `quantity`   | INT             | Quantity (min: 1)          |
| `created_at` | DATETIME        | Creation timestamp         |
| `updated_at` | DATETIME        | Last update timestamp      |

**Constraints:**
- UNIQUE `cart_product_UNIQUE` (`cart_id`, `product_id`) - One entry per product per cart

**Key Indexes:**
- `idx_cart_items_cart` (`cart_id`) - Cart lookup
- `idx_cart_items_product` (`product_id`) - Product lookup

### `coupons`

**Purpose:** Discount coupon management.

| Field                 | Type            | Description                          |
|-----------------------|-----------------|--------------------------------------|
| `id`                  | BIGINT UNSIGNED | Coupon ID (primary key)              |
| `code`                | VARCHAR(50)     | Coupon code (unique)                 |
| `description`         | TEXT            | Coupon description                   |
| `discount_type`       | ENUM            | Type: `PERCENTAGE`, `FIXED_AMOUNT`   |
| `discount_value`      | DECIMAL(15,2)   | Discount value (% or VNĐ)            |
| `min_order_amount`    | DECIMAL(15,2)   | Minimum order requirement            |
| `max_discount_amount` | DECIMAL(15,2)   | Maximum discount cap                 |
| `usage_limit`         | INT             | Total usage limit (NULL = unlimited) |
| `used_count`          | INT             | Times used                           |
| `user_usage_limit`    | INT             | Per-user limit (NULL = unlimited)    |
| `start_date`          | DATETIME        | Valid from                           |
| `end_date`            | DATETIME        | Valid until                          |
| `is_active`           | BOOLEAN         | Active status                        |
| `created_at`          | DATETIME        | Creation timestamp                   |
| `updated_at`          | DATETIME        | Last update timestamp                |

**Constraints:**
- UNIQUE `code_UNIQUE` (`code`) - Unique coupon codes

**Key Indexes:**
- `idx_coupons_active_dates` (`is_active`, `start_date`, `end_date`) - Active coupon lookup

**Discount Types:**
- **PERCENTAGE** - Percentage off (e.g., 10% off)
- **FIXED_AMOUNT** - Fixed amount off (e.g., 50,000 VNĐ off)

### `orders`

**Purpose:** Customer orders (main order table).

| Field                     | Type            | Description                                                                                    |
|---------------------------|-----------------|------------------------------------------------------------------------------------------------|
| `id`                      | BIGINT UNSIGNED | Order ID (primary key)                                                                         |
| `user_id`                 | BIGINT UNSIGNED | User reference (NULL for guest)                                                                |
| `code`                    | VARCHAR(50)     | Order code (unique, e.g., ORD-2025-00001)                                                      |
| `guest_token`             | VARCHAR(64)     | Guest token (NULL for user)                                                                    |
| `status`                  | ENUM            | Status: `PENDING`, `CONFIRMED`, `PROCESSING`, `SHIPPING`, `DELIVERED`, `CANCELLED`, `REFUNDED` |
| `payment_status`          | ENUM            | Payment: `UNPAID`, `PENDING`, `PAID`, `FAILED`, `REFUNDED`                                     |
| `payment_method`          | ENUM            | Method: `MOMO`, `COD`                                                                          |
| `recipient_name`          | VARCHAR(200)    | Recipient's name                                                                               |
| `recipient_phone`         | VARCHAR(15)     | Recipient's phone                                                                              |
| `shipping_street`         | VARCHAR(255)    | Shipping street address                                                                        |
| `shipping_ward`           | VARCHAR(100)    | Shipping ward                                                                                  |
| `shipping_city`           | VARCHAR(100)    | Shipping city                                                                                  |
| `shipping_postal_code`    | VARCHAR(6)      | Postal code                                                                                    |
| `shipping_country`        | VARCHAR(100)    | Country (default: Vietnam)                                                                     |
| `subtotal`                | DECIMAL(15,2)   | Products subtotal                                                                              |
| `shipping_fee`            | DECIMAL(15,2)   | Shipping cost                                                                                  |
| `discount_amount`         | DECIMAL(15,2)   | Discount applied                                                                               |
| `total_amount`            | DECIMAL(15,2)   | Final total (subtotal + shipping - discount)                                                   |
| `coupon_code`             | VARCHAR(50)     | Applied coupon code                                                                            |
| `note`                    | TEXT            | Customer notes                                                                                 |
| `admin_note`              | TEXT            | Internal admin notes                                                                           |
| `cancelled_reason`        | TEXT            | Cancellation reason                                                                            |
| `cancelled_by`            | ENUM            | Cancelled by: `CUSTOMER`, `STAFF`, `ADMIN`, `SYSTEM`                                           |
| `cancelled_at`            | DATETIME        | Cancellation timestamp                                                                         |
| `confirmed_at`            | DATETIME        | Confirmation timestamp                                                                         |
| `estimated_delivery_date` | DATE            | Estimated delivery                                                                             |
| `tracking_number`         | VARCHAR(100)    | Shipping tracking number                                                                       |
| `delivered_at`            | DATETIME        | Delivery timestamp                                                                             |
| `expired_at`              | DATETIME        | Payment expiration                                                                             |
| `created_at`              | DATETIME        | Order creation timestamp                                                                       |
| `updated_at`              | DATETIME        | Last update timestamp                                                                          |

**Order Status Flow:**
1. PENDING - Order created, awaiting payment/confirmation
2. CONFIRMED - Order confirmed, ready for processing
3. PROCESSING - Being prepared/packaged
4. SHIPPING - In transit to customer
5. DELIVERED - Successfully delivered
6. CANCELLED - Order cancelled
7. REFUNDED - Payment refunded

**Payment Methods:**
- **MOMO** - MoMo e-wallet payment
- **COD** - Cash on Delivery

**Constraint:** Either user_id OR guest_token must be set.

### `order_items`

**Purpose:** Line items in orders (snapshot of product at purchase time).

| Field             | Type            | Description                              |
|-------------------|-----------------|------------------------------------------|
| `id`              | BIGINT UNSIGNED | Order item ID (primary key)              |
| `order_id`        | BIGINT UNSIGNED | Order reference                          |
| `product_id`      | BIGINT UNSIGNED | Product reference                        |
| `product_code`    | VARCHAR(50)     | Product code snapshot                    |
| `product_name`    | VARCHAR(255)    | Product name snapshot                    |
| `quantity`        | INT             | Quantity ordered                         |
| `price`           | DECIMAL(15,2)   | Price at purchase time                   |
| `discount_amount` | DECIMAL(15,2)   | Item discount                            |
| `subtotal`        | DECIMAL(15,2)   | Line total (price * quantity - discount) |
| `created_at`      | DATETIME        | Creation timestamp                       |
| `updated_at`      | DATETIME        | Last update timestamp                    |

**Design Note:** Product name and code are stored to preserve historical accuracy even if product details change later.

### `order_status_history`

**Purpose:** Audit trail of order status changes.

| Field        | Type            | Description                             |
|--------------|-----------------|-----------------------------------------|
| `id`         | BIGINT UNSIGNED | History record ID (primary key)         |
| `order_id`   | BIGINT UNSIGNED | Order reference                         |
| `changed_by` | BIGINT UNSIGNED | User who changed status (NULL = system) |
| `old_status` | ENUM            | Previous status (NULL for new orders)   |
| `new_status` | ENUM            | New status                              |
| `note`       | TEXT            | Change notes                            |
| `created_at` | DATETIME        | Change timestamp                        |

**Key Indexes:**
- `idx_status_history_order_created` (`order_id`, `created_at`) - Order history chronology
- `idx_status_history_changed_by` (`changed_by`) - User activity tracking

### `momo_payments`

**Purpose:** MoMo payment gateway transaction tracking.

| Field            | Type            | Description                                                    |
|------------------|-----------------|----------------------------------------------------------------|
| `id`             | BIGINT UNSIGNED | Payment record ID (primary key)                                |
| `order_id`       | BIGINT UNSIGNED | Order reference                                                |
| `request_id`     | VARCHAR(50)     | MoMo request ID (unique)                                       |
| `order_info`     | VARCHAR(255)    | Order description for MoMo                                     |
| `amount`         | DECIMAL(15,2)   | Payment amount (VNĐ)                                           |
| `trans_id`       | VARCHAR(50)     | MoMo transaction ID                                            |
| `result_code`    | INT             | Result code (0 = success)                                      |
| `message`        | VARCHAR(500)    | MoMo response message                                          |
| `pay_url`        | TEXT            | Payment URL                                                    |
| `deep_link`      | TEXT            | MoMo app deep link                                             |
| `qr_code_url`    | TEXT            | QR code URL                                                    |
| `payment_status` | ENUM            | Status: `PENDING`, `SUCCESS`, `FAILED`, `EXPIRED`, `CANCELLED` |
| `request_time`   | DATETIME        | Request timestamp                                              |
| `response_time`  | DATETIME        | Response timestamp (IPN callback)                              |
| `ipn_data`       | JSON            | Full IPN data from MoMo                                        |
| `created_at`     | DATETIME        | Creation timestamp                                             |
| `updated_at`     | DATETIME        | Last update timestamp                                          |

**Constraints:**
- UNIQUE `request_id_UNIQUE` (`request_id`) - Unique MoMo requests

**Key Indexes:**
- `idx_momo_payments_order` (`order_id`) - Order lookup
- `idx_momo_payments_trans_id` (`trans_id`) - Transaction ID lookup
- `idx_momo_payments_status` (`payment_status`) - Status filtering

**Payment Flow:**
1. PENDING - Payment request created
2. SUCCESS - Payment completed successfully
3. FAILED - Payment failed
4. EXPIRED - Payment link expired
5. CANCELLED - Payment cancelled

### `coupon_usage`

**Purpose:** Track coupon usage history.

| Field             | Type            | Description                     |
|-------------------|-----------------|---------------------------------|
| `id`              | BIGINT UNSIGNED | Usage record ID (primary key)   |
| `coupon_id`       | BIGINT UNSIGNED | Coupon reference                |
| `user_id`         | BIGINT UNSIGNED | User reference (NULL for guest) |
| `order_id`        | BIGINT UNSIGNED | Order reference                 |
| `discount_amount` | DECIMAL(15,2)   | Actual discount applied         |
| `used_at`         | DATETIME        | Usage timestamp                 |
| `updated_at`      | DATETIME        | Last update timestamp           |

**Key Indexes:**
- `idx_coupon_usage_coupon` (`coupon_id`) - Coupon usage lookup
- `idx_coupon_usage_user` (`user_id`) - User usage tracking
- `idx_coupon_usage_order` (`order_id`) - Order lookup

---

## User Engagement & Content Tables

### `product_reviews`

**Purpose:** Customer product reviews and ratings.

| Field                  | Type            | Description                       |
|------------------------|-----------------|-----------------------------------|
| `id`                   | BIGINT UNSIGNED | Review ID (primary key)           |
| `product_id`           | BIGINT UNSIGNED | Product reference                 |
| `user_id`              | BIGINT UNSIGNED | Reviewer reference                |
| `order_id`             | BIGINT UNSIGNED | Related order (verified purchase) |
| `rating`               | TINYINT         | Star rating (1-5)                 |
| `title`                | VARCHAR(255)    | Review title                      |
| `comment`              | TEXT            | Review content                    |
| `is_verified_purchase` | BOOLEAN         | Verified purchase flag            |
| `is_approved`          | BOOLEAN         | Admin approval status             |
| `created_at`           | DATETIME        | Review creation timestamp         |
| `updated_at`           | DATETIME        | Last update timestamp             |

**Constraints:**
- CHECK `chk_rating_range` - Rating must be between 1 and 5
- CHECK `chk_verified_purchase` - Verified purchase requires order_id

**Key Indexes:**
- `idx_reviews_product_approved` (`product_id`, `is_approved`) - Approved product reviews
- `idx_reviews_user` (`user_id`) - User reviews
- `idx_reviews_order` (`order_id`) - Order reviews
- `idx_reviews_rating` (`rating`) - Rating filtering

### `wishlists`

**Purpose:** User product wishlists/favorites.

| Field        | Type            | Description               |
|--------------|-----------------|---------------------------|
| `id`         | BIGINT UNSIGNED | Wishlist ID (primary key) |
| `user_id`    | BIGINT UNSIGNED | User reference            |
| `product_id` | BIGINT UNSIGNED | Product reference         |
| `created_at` | DATETIME        | Creation timestamp        |
| `updated_at` | DATETIME        | Last update timestamp     |

**Constraints:**
- UNIQUE `user_product_UNIQUE` (`user_id`, `product_id`) - One entry per user-product pair

**Key Indexes:**
- `idx_wishlists_user` (`user_id`) - User wishlist lookup
- `idx_wishlists_product` (`product_id`) - Product popularity tracking

### `notifications`

**Purpose:** User notifications and alerts.

| Field        | Type            | Description                                               |
|--------------|-----------------|-----------------------------------------------------------|
| `id`         | BIGINT UNSIGNED | Notification ID (primary key)                             |
| `user_id`    | BIGINT UNSIGNED | User reference                                            |
| `type`       | ENUM            | Type: `ORDER`, `PAYMENT`, `PROMOTION`, `SYSTEM`, `REVIEW` |
| `title`      | VARCHAR(255)    | Notification title                                        |
| `message`    | TEXT            | Notification content                                      |
| `link`       | VARCHAR(500)    | Related link                                              |
| `is_read`    | BOOLEAN         | Read status                                               |
| `read_at`    | DATETIME        | Read timestamp                                            |
| `created_at` | DATETIME        | Creation timestamp                                        |
| `updated_at` | DATETIME        | Last update timestamp                                     |

**Key Indexes:**
- `idx_notifications_user_read` (`user_id`, `is_read`) - Unread notifications
- `idx_notifications_created` (`created_at`) - Notification chronology

**Notification Types:**
- **ORDER** - Order status updates
- **PAYMENT** - Payment notifications
- **PROMOTION** - Marketing promotions
- **SYSTEM** - System announcements
- **REVIEW** - Review reminders

### `faqs`

**Purpose:** Frequently Asked Questions.

| Field           | Type            | Description           |
|-----------------|-----------------|-----------------------|
| `id`            | BIGINT UNSIGNED | FAQ ID (primary key)  |
| `question`      | TEXT            | FAQ question          |
| `answer`        | TEXT            | FAQ answer (HTML)     |
| `category`      | VARCHAR(100)    | FAQ category          |
| `display_order` | INT             | Display order         |
| `is_active`     | BOOLEAN         | Visibility status     |
| `view_count`    | INT             | View counter          |
| `created_at`    | DATETIME        | Creation timestamp    |
| `updated_at`    | DATETIME        | Last update timestamp |

**Key Indexes:**
- `idx_faqs_category_active` (`category`, `is_active`) - Active FAQs by category
- `idx_faqs_display_order` (`display_order`) - Display ordering
- `idx_faqs_view_count` (`view_count`) - Popular FAQs

---

## System & Audit Tables

### `activity_logs`

**Purpose:** Complete system activity audit trail.

| Field         | Type            | Description                                     |
|---------------|-----------------|-------------------------------------------------|
| `id`          | BIGINT UNSIGNED | Log ID (primary key)                            |
| `user_id`     | BIGINT UNSIGNED | User who performed action (NULL = system/guest) |
| `action`      | VARCHAR(100)    | Action name (e.g., CREATE_ORDER)                |
| `entity_type` | VARCHAR(50)     | Entity type (e.g., ORDER, PRODUCT)              |
| `entity_id`   | BIGINT UNSIGNED | Entity ID                                       |
| `description` | TEXT            | Action description                              |
| `old_data`    | JSON            | Previous data (for rollback)                    |
| `new_data`    | JSON            | New data                                        |
| `ip_address`  | VARCHAR(45)     | IP address (IPv4/IPv6)                          |
| `user_agent`  | VARCHAR(500)    | Browser/device info                             |
| `created_at`  | DATETIME        | Action timestamp                                |
| `updated_at`  | DATETIME        | Last update timestamp                           |

**Key Indexes:**
- `idx_activity_logs_entity` (`entity_type`, `entity_id`) - Entity activity history
- `idx_activity_logs_created` (`created_at`) - Chronological log
- `idx_activity_logs_user` (`user_id`) - User activity tracking

**Use Cases:**
- Security auditing
- Change tracking
- Compliance reporting
- Debugging and troubleshooting

---

## Database Relationships

### One-to-One Relationships

- `users` → `user_profiles` - Each user has one profile
- `users` → `carts` - Each user has one cart (registered users)

### One-to-Many Relationships

- `users` → `addresses` - User can have multiple addresses
- `users` → `orders` - User can have multiple orders
- `brands` → `products` - Brand can have multiple products
- `categories` → `categories` - Category can have child categories (self-reference)
- `products` → `product_images` - Product can have multiple images
- `orders` → `order_items` - Order contains multiple items
- `orders` → `order_status_history` - Order has status change history
- `suppliers` → `purchases` - Supplier can have multiple purchase orders
- `purchases` → `purchase_items` - Purchase order contains multiple items
- `products` → `inventory_transactions` - Product has transaction history

### Many-to-Many Relationships

- `products` ↔ `categories` (via `product_categories`)
- `products` ↔ `features` (via `product_features`)
- `users` ↔ `products` (via `wishlists`)

### Polymorphic Relationships

- `guest_sessions` → `carts` - Guest token links to cart
- `guest_sessions` → `orders` - Guest token links to orders

---

## Indexing Strategy

### Primary Keys

All tables use `BIGINT UNSIGNED AUTO_INCREMENT` primary keys named `id`.

### Unique Indexes

- Email addresses (`users.email`)
- Product codes (`products.code`)
- Order codes (`orders.code`)
- Slugs (`categories.slug`, `brands.slug`, `products.slug`)
- Tokens (`guest_sessions.guest_token`)

### Composite Indexes

- `(user_id, is_default)` on `addresses` - Fast default address lookup
- `(product_id, is_primary)` on `product_images` - Fast primary image lookup
- `(is_active, start_date, end_date)` on `coupons` - Active coupon queries
- `(user_id, status)` on `orders` - User order history queries
- `(product_id, is_approved)` on `product_reviews` - Approved review queries

### Foreign Key Indexes

All foreign key columns are indexed for join performance.

---

## Data Integrity

### Foreign Key Constraints

**ON DELETE Behaviors:**
- `CASCADE` - Child records deleted with parent (e.g., order_items when order deleted)
- `RESTRICT` - Prevent parent deletion if children exist (e.g., brand with products)
- `SET NULL` - Set to NULL when parent deleted (e.g., category removed from product)

**ON UPDATE Behaviors:**
- `CASCADE` - Update child records when parent ID changes (all foreign keys)

### Check Constraints

- Product rating: 1-5 range
- Cart: Either user_id OR guest_token (not both)
- Order: Either user_id OR guest_token (not both)
- Review verified purchase: order_id required if verified

---

## Soft Deletes vs Hard Deletes

The schema uses **hard deletes** (actual deletion) for most tables, with the following exceptions:

**Soft Delete Pattern (is_active flag):**
- `users.is_active` - Deactivate instead of delete (preserve order history)
- `categories.is_active` - Hide instead of delete (preserve product links)
- `brands.is_active` - Deactivate instead of delete
- `products.is_active` - Hide instead of delete (preserve order history)

**Immutable Records (never delete):**
- `inventory_transactions` - Audit trail integrity
- `activity_logs` - Compliance and auditing
- `order_status_history` - Order audit trail

---

## Performance Considerations

### Partitioning Strategies

For high-traffic deployments, consider partitioning:
- `orders` - Partition by created_at (monthly or yearly)
- `activity_logs` - Partition by created_at (monthly)
- `inventory_transactions` - Partition by created_at (monthly)

### Archive Strategy

For data retention:
- Archive old orders (> 2 years) to separate table
- Archive old activity logs (> 1 year)
- Clean expired guest sessions daily
- Clean expired blacklisted tokens daily

### Query Optimization

- Use covering indexes for frequently queried columns
- Denormalize view counts and sold counts (updated via triggers or application)
- Cache product catalog in Redis/Memcached
- Use read replicas for reporting queries

---

## Backup and Recovery

### Backup Strategy

- **Full Backup:** Daily at 2 AM
- **Incremental Backup:** Every 6 hours
- **Transaction Log Backup:** Every hour
- **Retention:** 30 days for daily backups, 7 days for incremental

### Critical Tables (Priority Backup)

1. `orders` and `order_items` - Financial data
2. `users` and `user_profiles` - Customer data
3. `products` and inventory tables - Catalog data
4. `momo_payments` - Payment records

---

## Migration Considerations

### Schema Evolution

When modifying the schema:
1. Always use migration scripts (Flyway/Liquibase)
2. Test migrations on staging environment
3. Backup database before production migration
4. Plan for rollback procedures

### Backwards Compatibility

- Add new columns as NULL-able
- Deprecate before removing columns
- Use database views for legacy API compatibility
- Version control all schema changes

---

## Security Best Practices

### Sensitive Data

- Passwords stored as bcrypt hashes (never plaintext)
- Payment tokens encrypted at rest
- PII data (emails, phones) access logged
- Admin-only fields (cost_price) restricted by application layer

### Access Control

- Use database users with minimal privileges
- Application uses dedicated DB user (not root)
- Read-only user for reporting/analytics
- Audit all schema changes

---

## Next Steps

- [Module Architecture](module-architecture.md) - Application module structure
- [API Overview](../api/overview.md) - RESTful API documentation
- [Configuration Guide](../setup/configuration.md) - Database connection setup
- [Installation Guide](../setup/installation.md) - Development environment setup
