/* PROJECT: Olist E-commerce Data Exploration
OBJECTIVE: Understand structure, data quality, and table relationships before analysis

KEY QUESTIONS
1. What is the grain of each core table?
2. Which joins can create duplication?
3. Are there missing in key relationships?
4. Do item totals and payment totals reconcile at order level?
5. Are there obvious metric or timestamp anomalies?
 */

------------------------------
-- 1. CHECK CORE TABLE GRAIN
------------------------------

-- Orders should be one row per order_id
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders
FROM
    orders;

-- Order items should be one row per (order_id, order_item_id)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT CONCAT (order_id, '-', order_item_id)) AS unique_order_item_rows
FROM
    order_items;

-- Order payments should be one row per (order_id, payment_sequential)
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(
        DISTINCT CONCAT (order_id, '-', payment_sequential)
    ) AS unique_payment_rows
FROM
    order_payments;

-- Detect duplicate item rows at the expected grain
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM
    order_items
GROUP BY
    order_id,
    order_item_id
HAVING
    COUNT(*) > 1
ORDER BY
    duplicate_count DESC;

-- Detect duplicate payment rows at the expected grain
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM
    order_payments
GROUP BY
    order_id,
    payment_sequential
HAVING
    COUNT(*) > 1
ORDER BY
    duplicate_count DESC;

---------------------------
-- 2. CHECK JOIN RISK
---------------------------

-- Estimate join row explosion from joining items and payments tables
SELECT
    i.order_id,
    i.item_count,
    p.payment_count,
    (i.item_count * p.payment_count) AS expected_join_rows
FROM
    (
        SELECT
            order_id,
            COUNT(*) AS item_count
        FROM
            order_items
        GROUP BY
            order_id
    ) i
    JOIN (
        SELECT
            order_id,
            COUNT(*) AS payment_count
        FROM
            order_payments
        GROUP BY
            order_id
    ) p ON i.order_id = p.order_id
ORDER BY
    expected_join_rows DESC;

-- Quantify how many orders are exposed to join duplication risk
WITH
    order_counts AS (
        SELECT
            o.order_id,
            COUNT(DISTINCT oi.order_item_id) AS item_count, -- count distinct item rows in each order
            COUNT(DISTINCT op.payment_sequential) AS payment_count -- count distinct payment records in each order
        FROM
            orders o
            LEFT JOIN order_items oi ON o.order_id = oi.order_id
            LEFT JOIN order_payments op ON o.order_id = op.order_id
        GROUP BY
            o.order_id
    )
SELECT
    COUNT(*) AS total_orders,
    SUM(
        CASE
            WHEN item_count > 1 then 1
            ELSE 0
        END
    ) AS orders_with_multiple_items,
    SUM(
        CASE
            WHEN payment_count > 1 then 1
            ELSE 0
        END
    ) AS orders_with_multiple_payments,
    SUM(
        CASE
            WHEN item_count > 1
            AND payment_count > 1 then 1
            ELSE 0
        END
    ) AS orders_with_many_to_many_risk
FROM
    order_counts;

--> Key Insight: Aggregate order_items and order_payments before joining for order level metrics

-------------------------------------------
-- 3. CHECK RELATIONSHIPS AND MISSING DATA
-------------------------------------------

-- Orders with items but no payment records
SELECT
    oi.order_id,
    COUNT(*) AS item_count
FROM
    order_items oi
    LEFT JOIN order_payments op ON oi.order_id = op.order_id
WHERE
    op.order_id IS NULL
GROUP BY
    oi.order_id
ORDER BY
    item_count DESC;

--> Results: found 1 order with 3 items with no payment

-- Check the status of an order without payment records
SELECT
    o.order_status,
    COUNT(*) AS total
FROM
    (
        SELECT DISTINCT
            oi.order_id
        FROM
            order_items oi
            LEFT JOIN order_payments op ON oi.order_id = op.order_id
        WHERE
            op.order_id IS NULL
    ) t
    JOIN orders o ON t.order_id = o.order_id
GROUP BY
    o.order_status;

-- Summerise payment coverage across all orders
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT op.order_id) AS orders_with_payment,
    COUNT(DISTINCT o.order_id) - COUNT(DISTINCT op.order_id) AS orders_missing_payment
FROM
    orders o
    LEFT JOIN order_payments op ON o.order_id = op.order_id;

-- Check order items without a matching order
SELECT
    COUNT(*) AS orphan_item_rows
FROM
    order_items oi
    LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE
    o.order_id IS NULL;

-- Check order payments without a matching order
SELECT
    COUNT(*) AS orphan_payment_rows
FROM
    order_payments op
    LEFT JOIN orders o ON op.order_id = o.order_id
WHERE
    o.order_id IS NULL;

---------------------
-- 5. CHECK METRICS
---------------------

SELECT
    MIN(price),
    MAX(price),
    AVG(price)
FROM
    order_items;

SELECT
    MIN(payment_value),
    MAX(payment_value),
    AVG(payment_value)
FROM
    order_payments;

/* SUMMARY FOR ANALYSIS
- Use orders as the base grain
- Aggregate order_items to order level before joing with payments
- Exclue orders missing payment when calculating revenue