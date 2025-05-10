-- 7. Advanced SQL (CTEs, Window Functions, Pivots)
--	Rank products by sales quantity (using RANK()).

SELECT
	dp.ProductName,
	SUM(fs.SalesQuantity) AS TotalQuantity,
	RANK() OVER(ORDER BY SUM(fs.SalesQuantity) DESC) AS SalesRank
FROM
	FactSales fs
INNER JOIN DimProduct dp ON dp.ProductKey = fs.ProductKey
GROUP BY
    dp.ProductName,
    dp.ProductKey
ORDER BY
	SalesRank;

-- 	Calculate a 3-month moving average of sales.
WITH MonthlySales AS (
    -- First aggregate sales by month
    SELECT
        dd.CalendarYear,
        dd.CalendarMonth,
        dd.CalendarMonthLabel AS Month,
        SUM(fs.SalesAmount) AS TotalSales
    FROM
        FactSales fs
    JOIN
        DimDate dd ON fs.DateKey = dd.DateKey
    GROUP BY
        dd.CalendarYear,
        dd.CalendarMonth,
        dd.CalendarMonthLabel
)

SELECT
    CalendarYear,
    Month,
    TotalSales,
    AVG(TotalSales) OVER(
        ORDER BY CalendarYear, CalendarMonth
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS ThreeMonthMovingAvg
FROM
    MonthlySales
ORDER BY
    CalendarYear,
    CalendarMonth;

--	Compare actual sales vs. quota (FactSales vs. FactSalesQuota).
SELECT 
    fs.DateKey,
    dp.ProductName,
    fs.SalesAmount AS ActualSales,
    fsq.SalesAmountQuota AS SalesQuota,
    (fs.SalesAmount - fsq.SalesAmountQuota) AS SalesAmountVariance,
    CASE 
        WHEN fsq.SalesAmountQuota = 0 THEN NULL
        ELSE (fs.SalesAmount / fsq.SalesAmountQuota) * 100 
    END AS PercentToQuota
FROM 
    FactSales fs
JOIN 
    FactSalesQuota fsq ON fs.ProductKey = fsq.ProductKey 
                     AND fs.DateKey = fsq.DateKey
JOIN 
    DimProduct dp ON fs.ProductKey = dp.ProductKey
WHERE
    fs.DateKey BETWEEN '2007-01-01' AND '2009-12-31'
ORDER BY 
    SalesAmountVariance DESC;
USE ContosoRetailDW;
--	Find the percentage of total sales per product.
WITH ProductSales AS (
    SELECT
        dp.ProductKey,
        dp.ProductName,
        SUM(fs.SalesAmount) AS ProductSales
    FROM
        FactSales fs
    JOIN
        DimProduct dp ON fs.ProductKey = dp.ProductKey
    GROUP BY
        dp.ProductKey,
        dp.ProductName
),
GrandTotal AS (
    SELECT SUM(ProductSales) AS TotalSales FROM ProductSales
)
SELECT
    ps.ProductKey,
    ps.ProductName,
    ps.ProductSales,
    gt.TotalSales,
    (ps.ProductSales * 100.0 / gt.TotalSales) AS SalesPercentage
FROM
    ProductSales ps
CROSS JOIN
    GrandTotal gt
ORDER BY
    SalesPercentage DESC;

-- Use a CTE to find customers with lifetime value > $5000.
WITH CustomerLTV AS (
    -- Calculate total lifetime spending per customer
    SELECT
        fos.CustomerKey,
        SUM(fos.SalesAmount) AS LifetimeValue
    FROM
        FactOnlineSales fos
    GROUP BY
        fos.CustomerKey
    HAVING
        SUM(fos.SalesAmount) > 5000  -- Filter for high-value customers
)
-- Get customer details for those meeting the LTV threshold
SELECT
    c.CustomerKey,
    c.FirstName,
    c.LastName,
    c.EmailAddress,
    cltv.LifetimeValue
FROM
    DimCustomer c
JOIN
    CustomerLTV cltv ON c.CustomerKey = cltv.CustomerKey
ORDER BY
    cltv.LifetimeValue DESC;

--	Calculate YoY growth in sales.
WITH YearlySales AS (
    SELECT
        YEAR(DateKey) AS SalesYear,
        SUM(SalesAmount) AS TotalSales
    FROM
        FactSales
    GROUP BY
        YEAR(DateKey)
)
SELECT
    SalesYear,
    TotalSales AS CurrentYearSales,
    LAG(TotalSales) OVER (ORDER BY SalesYear) AS PreviousYearSales,
    CASE
        WHEN LAG(TotalSales) OVER (ORDER BY SalesYear) IS NULL THEN NULL
        ELSE (TotalSales - LAG(TotalSales) OVER (ORDER BY SalesYear)) / 
             LAG(TotalSales) OVER (ORDER BY SalesYear) * 100
    END AS YoYGrowthPercentage
FROM
    YearlySales
ORDER BY
    SalesYear;

-- Find the top 5% of customers by spending.
WITH CustomerSpending AS (
    SELECT
        c.CustomerKey,
        c.FirstName,
        c.LastName,
        c.EmailAddress,
        SUM(fos.SalesAmount) AS LifetimeValue,
        NTILE(20) OVER (ORDER BY SUM(fos.SalesAmount) DESC) AS PercentileGroup
    FROM
        FactOnlineSales fos
    JOIN
        DimCustomer c ON fos.CustomerKey = c.CustomerKey
    GROUP BY
        c.CustomerKey,
        c.FirstName,
        c.LastName,
        c.EmailAddress
)
SELECT
    CustomerKey,
    FirstName,
    LastName,
    EmailAddress,
    LifetimeValue,
    PercentileGroup
FROM
    CustomerSpending
WHERE
    PercentileGroup = 1  -- Top 5% (since NTILE(20) creates 20 groups of 5% each)
ORDER BY
    LifetimeValue DESC;

--	Identify consecutive days with outages.
WITH OutageDates AS (
    -- Get distinct outage dates and assign row numbers
    SELECT 
        DISTINCT CAST(OutageStartTime AS DATE) AS OutageDate,
        ROW_NUMBER() OVER (ORDER BY CAST(OutageStartTime AS DATE)) AS RowNum
    FROM 
        FactITSLA
),
OutageGroups AS (
    -- Identify groups of consecutive dates
    SELECT
        OutageDate,
        DATEADD(DAY, -RowNum, OutageDate) AS GroupDate
    FROM
        OutageDates
)
-- Count consecutive days and filter for significant periods
SELECT
    MIN(OutageStartTime) AS PeriodStart,
    MAX(OutageEndTime) AS PeriodEnd,
    COUNT(*) AS ConsecutiveDays,
    STRING_AGG(CONVERT(VARCHAR(10), OutageDate, 120), ', ') AS OutageDates
FROM
    FactITSLA
GROUP BY
    GroupDate
HAVING
    COUNT(*) >= 2  -- Only show periods with 2+ consecutive days
ORDER BY
    ConsecutiveDays DESC;

--	Use LAG() to compare monthly sales.
WITH MonthlySales AS (
    -- Aggregate sales by month
    SELECT
        YEAR(DateKey) AS SalesYear,
        MONTH(DateKey) AS SalesMonth,
        DATENAME(MONTH, DateKey) AS MonthName,
        SUM(SalesAmount) AS TotalSales
    FROM
        FactSales
    GROUP BY
        YEAR(DateKey),
        MONTH(DateKey),
        DATENAME(MONTH, DateKey)
)
SELECT
    SalesYear,
    MonthName,
    TotalSales AS CurrentMonthSales,
    LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) AS PreviousMonthSales,
    TotalSales - LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) AS MonthlyDifference,
    CASE
        WHEN LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) IS NULL THEN NULL
        WHEN LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) = 0 THEN NULL
        ELSE ROUND((TotalSales - LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth)) / 
                  LAG(TotalSales) OVER (ORDER BY SalesYear, SalesMonth) * 100, 2)
    END AS PercentChange
FROM
    MonthlySales
ORDER BY
    SalesYear,
    SalesMonth;