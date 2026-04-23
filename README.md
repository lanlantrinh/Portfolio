# 📊 Data Analytics Portfolio

Welcome to my portfolio! This repository showcases end-to-end data analytics projects, moving from complex data engineering and SQL modeling to high-impact, C-level Power BI dashboards. 

My analytical philosophy: **"Data is meaningless unless it drives a business decision."** I focus on solving real-world friction—like supply chain bottlenecks, revenue stagnation, and customer churn—rather than just building purely descriptive charts.

## 🚀 Featured Project

### 🛒 [Olist E-Commerce: Operations & CX Analytics](./01_olist_ecommerce)

An end-to-end business case study dissecting 100,000+ real e-commerce transactions to identify the root cause of late deliveries and quantifying the exact financial cost of bad customer experiences.

*   **Business Impact:** Identified severe transit bottlenecks in Northeast Brazil and proved the direct correlation between Missed SLAs (Late Deliveries) and massive spikes in 1-star reviews. Tracked the "illusion of growth" using MoM% velocity vs. absolute revenue volume.
*   **Data Engineering:** Built a highly optimized Star Schema Data Warehouse in PostgreSQL. Handled severe many-to-many cardinality risks between `order_items` and `order_payments` using SQL CTE pre-aggregation.
*   **BI & Analytics:** Developed a 3-tier consultant-grade Power BI dashboard suite (Executive, Logistics, Customer Experience). Leveraged advanced DAX (`CROSSFILTER`) to enable dynamic cross-filtering without compromising the core model integrity.
*   **Tech Stack:** PostgreSQL, SQL, Power BI, DAX, Data Modeling.

*(Click the link above to view the full case study and dashboard outcomes).*

## 📂 Project Structure

*   [`01_olist_ecommerce`](./01_olist_ecommerce) - Completed end-to-end E-commerce SQL data warehouse & Power BI project.
*   [`02_learning_analytics`](./02_learning_analytics) - (In Development)

## 🛠️ Core Competencies

*   **Data Modeling:** Star & Snowflake Schemas, Fact/Dim optimization, handling advanced relationship cardinalities.
*   **SQL:** Complex Window Functions, CTEs, Data Cleansing, view creation.
*   **Power BI / DAX:** Time Intelligence, Context Transition, dynamic visual formatting, C-level UI/UX dashboard design.

---
*Ready to translate complex data into your company's next strategic advantage? Let's connect.*
