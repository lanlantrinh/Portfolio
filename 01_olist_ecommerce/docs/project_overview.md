# Olist E-Commerce Analytics Portfolio

## 1. Project Summary
This end-to-end project transforms raw Olist e-commerce multi-table data (100k+ orders) in PostgreSQL into a highly optimized, trustworthy reporting layer for Power BI.

## 2. Business Architecture
The reporting suite drives actionable insights across three strategic core pillars:
1. **Executive Overview:** High-level trend analysis tracking valid revenue, order volume, Average Order Value (AOV), and top-performing categories.
2. **Logistics Performance:** Operational deep-dive to calculate On-Time Delivery Rate (OTDR), average delivery lead times, and pinpoint geo-spatial bottlenecks using Shape Maps.
3. **Customer Loyalty (Upcoming):** Retention, RFM segmentation, and Customer Satisfaction (CSAT) analysis through historic order reviews.

## 3. Data Engineering & Modeling Approach
To avoid severe multi-grain duplication risks (e.g., joining multiple items and payments directly), the database was re-architected into a clean **Star Schema**:
- **Accumulating Snapshot Fact Table (`fact_orders`):** Consolidated all critical delivery lifecycle timestamps (`purchase`, `approved`, `carrier`, `delivered`) into a single row per order. This aggressively optimizes time-intelligence calculations for Power BI's VertiPaq engine.
- **Safe Pre-Aggregation Pipeline:** Grouped and aggregated `order_items` and `order_payments` using SQL CTEs prior to joining with the base orders table, completely eliminating many-to-many errors.
- **Strict Logic Handling:** Mitigated order funnel blanks by strictly filtering out `Canceled` or `Unavailable` order statuses during DAX evaluations.

## 4. Outcome
The resulting SQL layer feeds a lightweight, highly interactive Power BI dashboard (`Porfolio_Olist.pbix`). The final product empowers stakeholders to dynamically drill down into complex performance metrics across temporal and geographical dimensions.
