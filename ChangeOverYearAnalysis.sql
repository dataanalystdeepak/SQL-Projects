
--Find the total sales by year where order date is not null.
SELECT 
	YEAR(order_date) AS YearOfSale,
	SUM(sales_amount) AS TotalSales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

--Find the total number of unique customers for each year.
SELECT 
	YEAR(order_date) AS YearOfCustomers,
	COUNT(DISTINCT customer_key) AS NumberOfCustomers
FROM gold.fact_sales
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

--Compare the previous year sales with current year and find the difference.
WITH CurrenyYearSales AS (
	SELECT
		YEAR(order_date) AS YearOfSales,
		SUM(sales_amount) AS SalesRevenue
	FROM gold.fact_sales
	WHERE YEAR(order_date) IS NOT NULL
	GROUP BY YEAR(order_date)
)

SELECT
*,
LAG(SalesRevenue) OVER(ORDER BY YearOfSales) AS PrevYearSales,
SalesRevenue - LAG(SalesRevenue) OVER(ORDER BY YearOfSales) AS DiffInSales
FROM CurrenyYearSales;

--Rank the top three products based on revenue generation for each year.
WITH ProdRevenue AS (
	SELECT
		YEAR(order_date) AS YearOfSale,
		product_key,
		SUM(sales_amount)	AS ProductRevenue
	FROM gold.fact_sales
	WHERE YEAR(order_date) IS NOT NULL
	GROUP BY YEAR(order_date), product_key
), 

Ranking AS (
	SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY YearOfSale ORDER BY ProductRevenue DESC) AS ProdRanking
	FROM ProdRevenue
)

SELECT
*
FROM Ranking
WHERE ProdRanking <=3;

--Show a running total of revenue month by month within each year.
WITH MonthlySales AS (
	SELECT 
		YEAR(order_date)			AS YearOfSale,
		MONTH(order_date)			AS MonthOfSale,
		SUM(sales_amount)			AS MonthlySales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT
*,
SUM(MonthlySales) OVER(PARTITION BY YearOfSale ORDER BY MonthOfSale )  AS RunningTotalOfSales
FROM MonthlySales;


--Find the three months moving average of sales for each year.
WITH MonthlySales AS (
	SELECT
		YEAR(order_date)			AS YearOfSale,
		MONTH(order_date)			AS MonthOfSale,
		SUM(sales_amount)			AS SalesRevenueForEachMonth
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY YEAR(order_date), MONTH(order_date)
)

SELECT
*,
AVG(SalesRevenueForEachMonth) OVER(PARTITION BY YearOfSale ORDER BY MonthOfSale ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg
FROM MonthlySales;
