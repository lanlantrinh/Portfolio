
-- 1. Dimension: Customers
CREATE OR REPLACE VIEW dim_customers AS
SELECT DISTINCT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM customers;

-- 2. Dimension: Categories
CREATE OR REPLACE VIEW dim_categories AS
SELECT DISTINCT
    COALESCE(product_category_name, 'unknown') AS product_category_name
FROM products;

-- 3. Fact: Orders (Order level granularity)
CREATE OR REPLACE VIEW fact_orders AS
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS total_item_value,
        SUM(freight_value) AS total_freight
    FROM order_items
    GROUP BY order_id
),
payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp::timestamp AS order_purchase_timestamp,
    o.order_approved_at::timestamp AS order_approved_at,
    o.order_delivered_carrier_date::timestamp AS order_delivered_carrier_date,
    o.order_delivered_customer_date::timestamp AS order_delivered_customer_date,
    o.order_estimated_delivery_date::timestamp AS order_estimated_delivery_date,
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS purchase_month,
    COALESCE(ia.item_count, 0) AS item_count,
    COALESCE(ia.total_item_value, 0) AS total_item_value,
    COALESCE(ia.total_freight, 0) AS total_freight,
    (COALESCE(ia.total_item_value, 0) + COALESCE(ia.total_freight, 0)) AS gross_order_value,
    pa.total_payment,
    (pa.total_payment IS NOT NULL) AS has_payment
FROM orders o
LEFT JOIN item_agg ia ON o.order_id = ia.order_id
LEFT JOIN payment_agg pa ON o.order_id = pa.order_id;

-- 4. Fact: Order Items (Order line level granularity)
CREATE OR REPLACE VIEW fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.shipping_limit_date::timestamp AS shipping_limit_date,
    COALESCE(p.product_category_name, 'unknown') AS product_category_name,
    oi.price AS item_revenue,
    oi.freight_value AS item_freight
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id;
