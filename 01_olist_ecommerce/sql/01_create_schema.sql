CREATE TABLE IF NOT EXISTS customers (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state TEXT
);

CREATE TABLE IF NOT EXISTS orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(customer_id),
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id TEXT REFERENCES orders(order_id),
    order_item_id INTEGER,
    product_id TEXT REFERENCES products(product_id),
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12, 2),
    freight_value NUMERIC(12, 2),
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE IF NOT EXISTS order_payments (
    order_id TEXT REFERENCES orders(order_id),
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(12, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

ALTER TABLE customers
    ADD COLUMN IF NOT EXISTS customer_unique_id TEXT,
    ADD COLUMN IF NOT EXISTS customer_zip_code_prefix INTEGER,
    ADD COLUMN IF NOT EXISTS customer_city TEXT,
    ADD COLUMN IF NOT EXISTS customer_state TEXT;

ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS order_approved_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS order_delivered_carrier_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS order_delivered_customer_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS order_estimated_delivery_date TIMESTAMP;

ALTER TABLE products
    ADD COLUMN IF NOT EXISTS product_name_lenght INTEGER,
    ADD COLUMN IF NOT EXISTS product_description_lenght INTEGER,
    ADD COLUMN IF NOT EXISTS product_photos_qty INTEGER,
    ADD COLUMN IF NOT EXISTS product_weight_g INTEGER,
    ADD COLUMN IF NOT EXISTS product_length_cm INTEGER,
    ADD COLUMN IF NOT EXISTS product_height_cm INTEGER,
    ADD COLUMN IF NOT EXISTS product_width_cm INTEGER;

ALTER TABLE order_items
    ADD COLUMN IF NOT EXISTS seller_id TEXT,
    ADD COLUMN IF NOT EXISTS shipping_limit_date TIMESTAMP;

ALTER TABLE order_payments
    ADD COLUMN IF NOT EXISTS payment_type TEXT,
    ADD COLUMN IF NOT EXISTS payment_installments INTEGER;

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_order_payments_order_id
    ON order_payments(order_id);
