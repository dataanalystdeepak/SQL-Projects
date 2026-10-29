# SQL Sales Analytics: Year-over-Year (YoY) & Performance Analysis

![SQL Server](https://img.shields.io/badge/SQL-SQL%20Server-blue)
![Window Functions](https://img.shields.io/badge/Window%20Functions-LAG%20%7C%20LEAD%20%7C%20NTILE%20%7C%20CUME__DIST%20%7C%20FIRST__VALUE-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

SQL projects that analyse multi-year sales data to answer real business questions: **How do sales change year over year? Which products and customers perform best? Where is the business growing or slowing down?**

Written in **T-SQL (SQL Server)** using **CTEs and window functions** on a data warehouse (gold layer) with a sales fact table and a product dimension.

---

## Table of Contents
- [Project Overview](#project-overview)
- [Dataset & Schema](#dataset--schema)
- [Skills Demonstrated](#skills-demonstrated)
- [Part 1: Change Over Year (YoY) Analysis](#part-1-change-over-year-yoy-analysis)
- [Part 2: Performance Analysis](#part-2-performance-analysis)
- [Key Insights](#key-insights)
- [How to Run](#how-to-run)
- [About Me](#about-me)

---

## Project Overview

| | |
|---|---|
| **Goal** | Turn raw sales data into business insights using advanced SQL |
| **Focus areas** | Year-over-year trends, product performance, customer segmentation |
| **Tools** | SQL Server, T-SQL, SSMS |
| **Techniques** | CTEs, window functions, aggregations, joins, CASE segmentation |
| **Total scenarios** | 12 (6 YoY + 6 Performance) |

---

## Dataset & Schema

Star-schema style data warehouse (gold layer) loaded from CSV files:

| Table / CSV | Type | Description | Key columns |
|---|---|---|---|
| `gold.fact_sales` | Fact | Sales transactions, one row per order line | `order_date`, `sales_amount`, `customer_key`, `product_key` |
| `gold.dim_products` | Dimension | Product details and categories | `product_key`, `product_id`, `product_name`, `category_id` |
| `gold.dim_customers` | Dimension | Customer details | `customer_key`, [add other columns, e.g. `customer_name`, `country`, `gender`, `birthdate`] |

**Relationships**
- `gold.fact_sales.product_key` → `gold.dim_products.product_key`
- `gold.fact_sales.customer_key` → `gold.dim_customers.customer_key`

The customer analyses (unique customers per year and Diamond / Gold / Silver segmentation) use `customer_key` from the sales table, which links to the customers table, so they can be extended with customer attributes such as country or age group.

Rows with a NULL `order_date` are excluded from every analysis.

---

## Skills Demonstrated

- **Window functions:** `LAG()`, `LEAD()`, `FIRST_VALUE()`, `ROW_NUMBER()`, `DENSE_RANK()`, `NTILE()`, `CUME_DIST()`, `SUM() OVER()`, `AVG() OVER()` (with frames such as `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW`)
- **Query structure:** multi-step CTEs
- **Data handling:** `INNER JOIN`, `GROUP BY`, `COUNT(DISTINCT)`, NULL handling, date functions (`YEAR`, `MONTH`)
- **Business analysis:** YoY difference, running totals, moving averages, ranking, benchmarking against a leader, above-average detection, customer segmentation, percentile-based filtering

---

## Part 1: Change Over Year (YoY) Analysis

| # | Business question | Key techniques |
|---|---|---|
| 1 | What are the total sales for each year? | `SUM`, `YEAR`, `GROUP BY` |
| 2 | How many unique customers bought each year? | `COUNT(DISTINCT)` |
| 3 | How do current-year sales compare with the previous year, and what is the difference? | CTE, `LAG()` |
| 4 | Which are the top 3 products by revenue each year? | `ROW_NUMBER()`, `PARTITION BY` |
| 5 | What is the month-by-month running total of revenue within each year? | `SUM() OVER (PARTITION BY ... ORDER BY ...)` |
| 6 | What is the 3-month moving average of sales within each year? | `AVG() OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` |

---

## Part 2: Performance Analysis

| # | Business question | Key techniques |
|---|---|---|
| 1 | Who are the top 3 products within each category for every year? | `DENSE_RANK()`, `ROW_NUMBER()`, multi-column `PARTITION BY` |
| 2 | Which products earned above their category's average revenue in 2011? | `AVG() OVER (PARTITION BY category_id)` |
| 3 | What is the % change from one year to the next for each category? | `LEAD()`, percentage calculation |
| 4 | How far behind the top product is every other product in its category (2011)? | `FIRST_VALUE()` benchmark |
| 5 | How can customers be split into Diamond, Gold and Silver segments each year? | `NTILE(3)`, `CASE` |
| 6 | Which products are in the top 25% by revenue each year? | `CUME_DIST()` |

---


## Key Insights

**Change over year**
- **Sales trend:** [e.g., Total sales grew over years.]
- **Customer base:** [e.g., Unique customers increased over years.]
- **Seasonality:** [e.g., Running totals show most revenue arrives in months X to Y.]
- **Trend smoothing:** [e.g., The 3-month moving average shows a dip around month X.]

**Performance**
- **Top products:** [e.g., Product X was the top seller in category Y for N consecutive years.]
- **Above-average products (2011):** [e.g., Only N products earned above their category average, showing revenue is concentrated in a few items.]
- **Category growth:** [e.g., Category X grew by Y% year over year while category Z declined.]
- **Gap from the leader (2011):** [e.g., The second-best product in category X earns only Y% of the leader's revenue.]
- **Customer segments:** [e.g., Diamond customers contribute X% of revenue each year.]
- **Top 25% products:** [e.g., The top quarter of products generates X% of annual revenue.]

---


## How to Run

1. Install **SQL Server** and **SQL Server Management Studio (SSMS)**.
2. Load the CSV files from the `dataset/` folder into the gold-layer tables `gold.fact_sales`, `gold.dim_products` and `gold.dim_customers`.
3. Run the scripts available in DatabaseAndSchemaCreation to create Database and Schema
4. Open `01_change_over_year_analysis.sql` or `02_performance_analysis.sql` in SSMS.
5. Run each query separately and review the output.

---

## About Me

Hi, I'm **Deepak Singh**, an English language trainer moving into **Data Analytics**. I build hands-on SQL projects to turn data into clear, simple insights. I'm looking for a **Data Analyst** role where I can apply my communication skills to explain data stories and keep learning from a team.

- Phone: +91-7607146249
- Email: coachdeepaksingh@gmail.com

---

If you find this project useful, please give it a ⭐
