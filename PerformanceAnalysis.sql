
-- 1) Find the top three high performing products within each category for every year and rank them.
WITH ProdRevenue AS (
	SELECT 
		YEAR(s.order_date)				AS YearOfSale,
		p.category_id,
		p.product_id,
		SUM(s.sales_amount)				AS SalesFromProduct
	FROM gold.fact_sales				AS s
	INNER JOIN gold.dim_products		AS p ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.category_id, p.product_id
),

ProdRanking AS (
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY YearOfSale, category_id ORDER BY SalesFromProduct DESC) AS DenseRank,
		ROW_NUMBER() OVER(PARTITION BY YearOfSale, category_id ORDER BY SalesFromProduct DESC) AS RowNumber
	FROM ProdRevenue
)

SELECT *
FROM ProdRanking
WHERE RowNumber <=3;

--2) Find the products whose revenue is above average revenue of each category for year 2011.
WITH ProdRevenue AS ( 
    SELECT 
        YEAR(s.order_date) AS YearOfSale, 
        p.category_id, 
        s.product_key, 
        SUM(s.sales_amount) AS SalesFromProd 
    FROM gold.fact_sales AS s 
    INNER JOIN gold.dim_products AS p ON p.product_key = s.product_key 
    WHERE s.order_date IS NOT NULL 
      AND s.order_date BETWEEN '2011-01-01' AND '2011-12-31'
    GROUP BY YEAR(s.order_date), p.category_id, s.product_key 
), 
AverageRevenue AS ( 
    SELECT 
        *, 
        AVG(SalesFromProd) OVER(PARTITION BY category_id) AS CatAverage
    FROM ProdRevenue 
) 
SELECT * 
FROM AverageRevenue 
WHERE SalesFromProd > CatAverage;


--3) Find the % difference in sales of next year from the sales of previous year for each category.
WITH YearWiseSales AS (
    SELECT
        YEAR(s.order_date)          AS YearOfSale,
        p.category_id,
        SUM(s.sales_amount)         AS RevenueByCategory
    FROM gold.fact_sales            AS s
    INNER JOIN gold.dim_products    AS p ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.category_id
),
NextYearSales AS (
    SELECT
        *,
        LEAD(RevenueByCategory) OVER(PARTITION BY category_id ORDER BY YearOfSale) AS SaleOfNextYear
    FROM YearWiseSales
)
SELECT
    *,
    ((SaleOfNextYear - RevenueByCategory) * 100.0 / RevenueByCategory) AS PercentDiff
FROM NextYearSales
ORDER BY YearOfSale, category_id;


--4) Find the highest revenue generating product within each category and compare its revenue with other product's revenue for year 2011.

WITH ProdRevenue AS ( 
    SELECT 
        YEAR(s.order_date) AS YearOfSale, 
        p.category_id, 
        s.product_key, 
        SUM(s.sales_amount) AS SalesFromProd 
    FROM gold.fact_sales AS s 
    INNER JOIN gold.dim_products AS p ON p.product_key = s.product_key 
    WHERE s.order_date IS NOT NULL 
      AND s.order_date BETWEEN '2011-01-01' AND '2011-12-31'
    GROUP BY YEAR(s.order_date), p.category_id, s.product_key 
)

SELECT 
*,
FIRST_VALUE(SalesFromProd) OVER(PARTITION BY category_id ORDER BY SalesFromProd DESC)  AS TopProdRev,
FIRST_VALUE(SalesFromProd) OVER(PARTITION BY category_id ORDER BY SalesFromProd DESC) - SalesFromProd AS DiffInRevenue
FROM ProdRevenue
ORDER BY YearOfSale, category_id, SalesFromProd DESC;


--5) Classify the customers into three segments based on the revenue earned through them for every year.
WITH RevenueByCustomers AS (
	SELECT 
		YEAR(order_date)		AS YearOfSale,
		customer_key,
		SUM(sales_amount)		AS SalesThroughCustomers
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), customer_key
), 

CustomerSegments AS (
	SELECT
		*,
		NTILE(3) OVER(PARTITION BY YearOfSale ORDER BY SalesThroughCustomers DESC) AS CustSegment
	FROM RevenueByCustomers
)

SELECT 
*,
	CASE
		WHEN CustSegment = 1 THEN 'Diamond'
		WHEN CustSegment = 2 THEN 'Gold'
	ELSE 'Silver'
	END		AS CustomerType
FROM CustomerSegments
ORDER BY YearOfSale;

--6) Find the top 25% products by revenues for every year.
WITH RevenueByProducts AS (
	SELECT
		YEAR(s.order_date)				AS YearOfSale,
		p.product_key,
		p.product_name,
		SUM(s.sales_amount)				AS SalesByProduct
	FROM gold.fact_sales				AS s
	INNER JOIN gold.dim_products		AS p ON p.product_key = s.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.product_key, p.product_name
) ,

ProdContrInRevenue AS (
	SELECT
	*,
	CUME_DIST() OVER(PARTITION BY YearOfSale ORDER BY SalesByProduct DESC) AS RevenueContribution
	FROM RevenueByProducts
)

SELECT *
FROM ProdContrInRevenue
WHERE RevenueContribution <= .25;