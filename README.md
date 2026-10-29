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
- [Sample Queries](#sample-queries)
- [Key Insights](#key-insights)
- [Repository Structure](#repository-structure)
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

Star-schema style data warehouse (gold layer):

| Table | Description | Columns used |
|---|---|---|
| `gold.fact_sales` | Sales transactions | `order_date`, `sales_amount`, `customer_key`, `product_key` |
| `gold.dim_products` | Product details | `product_key`, `product_id`, `product_name`, `category_id` |

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

## Sample Queries

### Previous year vs current year sales (YoY difference)

```sql
WITH CurrentYearSales AS (
    SELECT
        YEAR(order_date)  AS YearOfSales,
        SUM(sales_amount) AS SalesRevenue
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    *,
    LAG(SalesRevenue) OVER (ORDER BY YearOfSales)                  AS PrevYearSales,
    SalesRevenue - LAG(SalesRevenue) OVER (ORDER BY YearOfSales)   AS DiffInSales
FROM CurrentYearSales;
```

### Customer segments per year (NTILE + CASE)

```sql
WITH RevenueByCustomers AS (
    SELECT
        YEAR(order_date)  AS YearOfSale,
        customer_key,
        SUM(sales_amount) AS SalesThroughCustomers
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date), customer_key
),
CustomerSegments AS (
    SELECT
        *,
        NTILE(3) OVER (PARTITION BY YearOfSale ORDER BY SalesThroughCustomers DESC) AS CustSegment
    FROM RevenueByCustomers
)
SELECT
    *,
    CASE
        WHEN CustSegment = 1 THEN 'Diamond'
        WHEN CustSegment = 2 THEN 'Gold'
        ELSE 'Silver'
    END AS CustomerType
FROM CustomerSegments
ORDER BY YearOfSale;
```

### Top 25% products by revenue each year (CUME_DIST)

```sql
WITH RevenueByProducts AS (
    SELECT
        YEAR(s.order_date)  AS YearOfSale,
        p.product_key,
        p.product_name,
        SUM(s.sales_amount) AS SalesByProduct
    FROM gold.fact_sales AS s
    INNER JOIN gold.dim_products AS p ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_key, p.product_name
),
ProdRank AS (
    SELECT
        *,
        CUME_DIST() OVER (PARTITION BY YearOfSale ORDER BY SalesByProduct DESC) AS CumeDistPos
    FROM RevenueByProducts
)
SELECT *
FROM ProdRank
WHERE CumeDistPos <= 0.25
ORDER BY YearOfSale, SalesByProduct DESC;
```

`CUME_DIST()` is calculated separately for each year. A value of 0.25 or less means the product is in the top quarter by revenue for that year (top 25% by product count, not 25% of revenue).

---

## Key Insights

> Replace the placeholders with your real findings and numbers. Specific figures make the README far more convincing.

**Change over year**
- **Sales trend:** [e.g., Total sales grew from X in 20XX to Y in 20XX; the largest year-on-year jump was in 20XX.]
- **Customer base:** [e.g., Unique customers increased from X to Y between 20XX and 20XX.]
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

## Repository Structure

```
sql-sales-analytics/
│
├── README.md
├── 01_change_over_year_analysis.sql
├── 02_performance_analysis.sql
└── screenshots/
    └── query-output-samples.png
```

---

## How to Run

1. Install **SQL Server** and **SQL Server Management Studio (SSMS)**.
2. Load the gold-layer tables `gold.fact_sales` and `gold.dim_products`.
3. Open `01_change_over_year_analysis.sql` or `02_performance_analysis.sql` in SSMS.
4. Run each query separately and review the output.

---

## About Me

Hi, I'm **Deepak**, an English language trainer moving into **data analytics**. I build hands-on SQL projects to turn data into clear, simple insights. I'm looking for a **Data Analyst** role where I can apply my communication skills to explain data stories and keep learning from a team.

- LinkedIn: [your-link]
- Email: [your-email]

---

If you find this project useful, please give it a ⭐
