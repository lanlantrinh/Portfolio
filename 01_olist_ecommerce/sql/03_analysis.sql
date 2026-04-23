/* KEY BUSINESS QUESTIONS
    1. How does revenue change over time?
    2. Which product categories generate the most revenue?
    3. Do customers in certain states spend more?
*/

-- Run 04_create_views.sql before these queries.
-- clean_orders = order grain
-- clean_order_category_sales = order-category grain

-- Q1. How does revenue change over time?
-- Revenue uses payment_value and excludes canceled / unavailable orders.
SELECT
    purchase_month AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment) AS revenue,
    AVG(total_payment) AS avg_order_value
FROM clean_orders
WHERE has_payment = TRUE
  AND order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY 1;

-- Q2. Which product categories generate the most revenue?
-- Category revenue uses item price because payment_value cannot be allocated
-- safely across multiple categories within the same order.
SELECT
    product_category_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(item_count) AS items_sold,
    SUM(category_item_revenue) AS revenue
FROM clean_order_category_sales
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;

-- Q3. Do customers in certain states spend more?
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_payment) AS total_revenue,
    AVG(total_payment) AS avg_order_value
FROM clean_orders
WHERE has_payment = TRUE
  AND order_status NOT IN ('canceled', 'unavailable')
GROUP BY 1
ORDER BY total_revenue DESC;
