# Olist E-Commerce Analytics Case Study

## 1. Project Summary
This end-to-end project transforms raw Olist e-commerce multi-table data (100k+ orders) in PostgreSQL into a highly optimized, trustworthy reporting layer for Power BI.

## 2. Business Architecture
The reporting suite drives actionable insights across three strategic core pillars:
1. **Executive Overview:** Dissects absolute revenue volume versus true month-over-month (MoM) momentum, tracking KPIs and geographic distributions.
2. **Logistics Performance:** Operational deep-dive separating processing times from transit delays, pinpointing severe regional delivery bottlenecks (e.g., RJ, AL).
3. **Customer Experience (CX):** A robust analysis directly correlating delivery SLA misses to massive spikes in 1-star reviews, and identifying high-risk product categories via a dynamic Scatter Matrix.

## 3. Data Engineering & Modeling Approach
To avoid severe multi-grain duplication risks (e.g., joining multiple items and payments directly), the database was re-architected into a clean **Star Schema**:
- **Accumulating Snapshot Fact Table (`fact_orders`):** Consolidated all critical delivery lifecycle timestamps into a single row per order. This aggressively optimizes time-intelligence calculations for Power BI's VertiPaq engine.
- **Safe Pre-Aggregation Pipeline:** Grouped and aggregated `order_items` and `order_payments` using SQL CTEs prior to joining with the base orders table, completely eliminating many-to-many cardinality errors.
- **Strict Logic Handling & Advanced DAX:** Implemented robust targeted DAX (like `CROSSFILTER`) to safely enable cross-filtering between Product Categories and Reviews without permanently altering the Star Schema directionality.

## 4. Outcome
The resulting SQL layer feeds a lightweight, highly interactive Power BI dashboard (`Porfolio_Olist.pbix`). The final product empowers stakeholders to dynamically drill down into complex performance metrics across temporal and geographical dimensions, shifting the conversation from "What happened?" to "What needs fixing?".
