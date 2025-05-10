--Connect My Database
USE ContosoRetailDW;

------- 1. Basic SELECT Queries (Single Table)------
--Retrieve all columns from DimCustomer

SELECT * 
FROM 
	DimCustomer;
-- List only FirstName, LastName, and EmailAddress from DimCustomer.
SELECT 
	FirstName, 
	LastName, 
	EmailAddress
FROM 
	DimCustomer;

-- Find all products where ClassName Deluxe in DimProduct.
SELECT *
FROM 
	DimProduct
WHERE 
	ClassName= 'Deluxe';

SELECT DISTINCT 
	ClassName 
FROM 
	DimProduct;

-- Count how many employees are salaried in DimEmployee.
SELECT 
	count (SalariedFlag) AS number_salaried 
FROM 
	DimEmployee
WHERE 
	SalariedFlag=1;

-- List promotions with a Discount Percentage greater than 10% from DimPromotion.
SELECT * 
FROM
	DimPromotion
WHERE 
	DiscountPercent >0.1;

-- Find stores that are currently open in DimStore.
SELECT * 
FROM 
	DimStore
WHERE 
	Status = 'On';

SELECT DISTINCT 
	status 
FROM 
	DimStore;

-- List all currencies and their labels.
SELECT DISTINCT 
	CurrencyName, CurrencyLabel
FROM 
	DimCurrency;

-- Find machines with Machine Type containing 'POS' in DimMachine.
SELECT *
FROM 
	DimMachine
WHERE 
	MachineType Like '%POS%';

-- List outage types (OutageType) and their descriptions from DimOutage.
SELECT DISTINCT 
			OutageType, OutageTypeDescription
FROM 
	DimOutage;

-- Retrieve products with a UnitPrice > $100 from DimProduct.
SELECT *
FROM 
	DimProduct
WHERE
	UnitPrice>100;


--------2. Filtering and Sorting-------
-- List customers sorted by YearlyIncome (highest to lowest)
SELECT 
	Title,
	FirstName,
	LastName,
	BirthDate,
	YearlyIncome
FROM 
	DimCustomer
ORDER BY 
	YearlyIncome DESC;

--Find employees hired in the last 5 years (HireDate filter).
--Given that the max of the hire date is '2003-07-01' and the min is '1996-07-31'
--we goning to suppose that is the last 5 years from 2003
SELECT
	min(HireDate) 
FROM 
	DimEmployee;

SELECT 
	max(HireDate) 
FROM 
	DimEmployee;

SELECT 
	FirstName,
	LastName,
	Title,
	HireDate,
	BirthDate
FROM 
	DimEmployee
WHERE
	HireDate>= DATEADD(YEAR,-5,'2003-07-01')
ORDER BY 
	HireDate DESC;

-- List products with Available For Sale in 2009.
SELECT 
	ProductLabel,
	ProductName,
	ProductDescription,
	ProductSubcategoryKey,
	AvailableForSaleDate
FROM 
	DimProduct
WHERE 
	DATEPART(Year, AvailableForSaleDate)='2009';

-- Find promotions that ended before 2009.
SELECT *
FROM 
	DimPromotion
WHERE 
	DATEPART(YEAR, EndDate)<'2009';

--List stores in 'United States'

SELECT *
FROM 
	DimStore ds
LEFT JOIN 
	DimGeography dg on ds.GeographyKey = dg.GeographyKey
WHERE 
	dg.RegionCountryName = 'United States';

--	Find customers with Total Children greater than 2 and HouseOwnerFlag = 1.
SELECT *
FROM 
	DimCustomer
WHERE 
	TotalChildren>2 AND HouseOwnerFlag=1;

-- List products with Size contained 40 and ColorName = 'Red'.
SELECT 
	ProductKey,
	ProductLabel,
	ProductName,
	ProductSubcategoryKey,
	Size,
	ColorName
FROM 
	DimProduct
WHERE 
	Size like '%40%' AND ColorName = 'Red';

--	Find outages that lasted more than 60 minutes (Find DownTime in FactITSLA).
SELECT 
	do.OutageKey,
	do.OutageLabel,
	do.OutageName,
	do.OutageType,
	do.OutageTypeDescription,
	fi.Downtime
FROM DimOutage do
LEFT JOIN 
	FactITSLA fi ON do.OutageKey=fi.OutageKey
WHERE 
	fi.DownTime > 60;

--	List employees with Vacation Hours less than 10 (sorted by LastName).
SELECT	
	Concat(LastName,' ', FirstName) AS Full_name,
	Title,
	HireDate,
	BirthDate,
	VacationHours
FROM 
	DimEmployee
WHERE 
	VacationHours <10
ORDER BY
	Full_name ASC;

--	Retrieve sales transactions with ReturnQuantity > 0.
SELECT 
	SalesKey,
	UnitCost,
	UnitPrice,
	SalesQuantity,
	ReturnQuantity

FROM 
	FactSales
WHERE 
	ReturnQuantity>0;

--------3. Joins (Multi-Table Queries)-------------
--	List ProductName and SalesAmount.

SELECT 
	fs.SalesKey,
	fs.DateKey,
	dp.ProductName,
	fs.SalesAmount

FROM 
	FactSales fs
LEFT JOIN 
	DimProduct dp ON fs.ProductKey=dp.ProductKey
ORDER BY 4 DESC;

--	Find customers and their geography (CityName, Country).
SELECT 
	dc.CustomerKey,
	dc.GeographyKey,
	dc.FirstName,
	dc.LastName,
	dg.CityName,
	dg.RegionCountryName
FROM 
	DimCustomer dc
LEFT JOIN 
		DimGeography dg ON dc.GeographyKey=dg.GeographyKey;

--  List employees and their manager’s name (self-join on ParentEmployeeKey)
SELECT 
	CONCAT(de1.FirstName,' ',de1.LastName) as EmployeeName,
	CONCAT(de2.FirstName,' ',de2.LastName) AS ManagerName

FROM 
	DimEmployee de1
LEFT JOIN 
	DimEmployee de2 ON de1.ParentEmployeeKey = de2.EmployeeKey;

--	Show StoreName + SalesTerritoryRegion .
--By using Dimstore and DimSalesTerritory database
SELECT DISTINCT 
	ds.StoreName,
	dst.SalesTerritoryRegion
FROM 
	DimStore ds
LEFT JOIN 
	DimSalesTerritory dst ON ds.GeographyKey=dst.GeographyKey
ORDER BY 1 ASC;

--	List products with their ProductCategoryName
WITH sub AS
			(SELECT 
				dpc.ProductCategoryName,
				dps.ProductSubcategoryKey
			FROM 
				DimProductCategory  dpc
			LEFT JOIN 
				DimProductSubcategory dps ON  dpc.ProductCategoryKey = dps.ProductCategoryKey		
			)
SELECT 
	dp.ProductKey,
	--s.ProductCategoryKey,
	dp.ProductName,
	s.ProductCategoryName
FROM 
	DimProduct dp
LEFT JOIN 
	sub s ON dp.ProductSubcategoryKey=s.ProductSubcategoryKey;

--	Find machines and their associated store names.
SELECT 
	dm.MachineKey,
	dm.StoreKey,
	dm.MachineLabel,
	dm.MachineName,
	ds.StoreName,
	dm.MachineDescription
FROM 
	DimMachine dm
LEFT JOIN 
	DimStore ds ON dm.StoreKey = ds.StoreKey;

--	List promotions applied to sales 
--(join FactSales + DimPromotion).
SELECT 
	fs.SalesKey,
	fs.SalesAmount,
	dp.PromotionName,
	dp.PromotionType,
	dp.DiscountPercent
FROM 
	FactSales fs
LEFT JOIN 
		DimPromotion dp ON fs.PromotionKey = dp.PromotionKey
WHERE 
	dp.DiscountPercent >0
ORDER BY 
	dp.DiscountPercent ASC;

--	Show all ProductName and the InventoryQuantity 
--(join DimProduct + FactInventory).
SELECT DISTINCT 
	dp.ProductKey,
	dp.ProductName,
	dp.ProductDescription,
	fi.OnHandQuantity
	--ds.StoreName
FROM 
	DimProduct dp
INNER JOIN 
	FactInventory fi ON dp.ProductKey = fi.ProductKey
--LEFT JOIN 
			--DimStore ds ON ds.StoreKey = fi.StoreKey
WHERE 
	fi.OnHandQuantity >0 
ORDER BY
	dp.ProductKey ASC,
	fi.OnHandQuantity ASC;

--	List customers who made online purchases 
--(join DimCustomer + FactOnlineSales).
SELECT 
	CONCAT(dc.FirstName,' ',dc.LastName) AS FullName,
	SUM(fos.SalesAmount) AS TotalAmount		
FROM 
	DimCustomer dc
LEFT JOIN 
	FactOnlineSales fos ON dc.CustomerKey = fos.CustomerKey
GROUP BY 
	CONCAT(dc.FirstName,' ',dc.LastName);

--	Find sales with currency conversion details 
--(join FactSales + DimCurrency).
SELECT 
	fs.SalesKey,
	fs.SalesAmount,
	dc.CurrencyLabel,
	dc.CurrencyName

FROM 
	FactSales fs
LEFT JOIN 
		DimCurrency dc ON fs.CurrencyKey = dc.CurrencyKey;

----------4 Aggregations (GROUP BY, SUM, AVG, etc.)------
--	Calculate total SalesAmount by ProductKey.
--In store Data sales--
SELECT 
	ProductKey,
	SUM(SalesAmount) AS TotalSalesAmount

FROM 
	FactSales
GROUP BY 
		ProductKey
ORDER BY 2 DESC;

--In Online Data sales--
SELECT 
	ProductKey,
	SUM(SalesAmount) AS TotalSalesAmount

FROM 
	FactOnlineSales
GROUP BY 
		ProductKey
ORDER BY 2 DESC;

--	Count sales transactions per StoreKey.
SELECT 
	StoreKey,
	COUNT(SalesKey) AS NumberTransactions
FROM 
	FactSales
GROUP BY 
		StoreKey
ORDER BY 2 ASC;

--	Find average YearlyIncome by Education level.
SELECT 
	Education,
	AVG(YearlyIncome) AS AverageIncome
FROM 
	DimCustomer
--WHERE Education is not null
GROUP BY
		Education
ORDER BY 2 ASC;

--	Sum quantity of product in inventory by product category.
WITH 
	sub AS
			(SELECT 
				dpc.ProductCategoryName,
				dps.ProductSubcategoryKey

			FROM 
				DimProductCategory  dpc
			LEFT JOIN 
				DimProductSubcategory dps ON  dpc.ProductCategoryKey = dps.ProductCategoryKey		
			),
	cat AS 
			(SELECT 
				dp.ProductKey,
				--s.ProductCategoryKey,
				dp.ProductName,
				s.ProductCategoryName
			FROM 
				DimProduct dp
			LEFT JOIN 
					sub s ON dp.ProductSubcategoryKey=s.ProductSubcategoryKey)
SELECT 
	c.ProductCategoryName AS ProductCategory,
	SUM(fi.OnOrderQuantity)
FROM 
	FactInventory fi
LEFT JOIN 
	cat c ON fi.ProductKey = c.ProductKey
GROUP BY 
		c.ProductCategoryName
ORDER BY 2 DESC;

--	Calculate total DownTime by OutageType.
SELECT 
	do.OutageType,
	SUM(fia.DownTime) AS TotalDownTime
FROM 
	FactITSLA fia
LEFT JOIN 
	DimOutage do ON do.OutageKey = fia.OutageKey
GROUP BY
	do.OutageType
ORDER BY 2 ASC;

--	Find the most common ProductColor in sales
--In store sales--
SELECT 
	dp.ColorName AS ProductColor,
	SUM(fs.SalesAmount) AS TotalSalesAmount
FROM 
	FactSales fs
LEFT JOIN 
	DimProduct dp ON dp.ProductKey = fs.ProductKey
GROUP BY 
	dp.ColorName
ORDER BY 2 DESC;

--	Calculate average DiscountPercent by PromotionCategory
SELECT 
	PromotionCategory,
	AVG(DiscountPercent) AS AvergaeDiscountPercent
FROM 
	DimPromotion
GROUP BY 
		PromotionCategory
ORDER BY 2 DESC;

--	Sum ReturnAmount by customer on online.
--In store Data
SELECT	
	CONCAT(dc.FirstName,' ',dc.LastName) AS FullName,
	SUM(fos.ReturnAmount) AS TotalReturnAmount
FROM 
	DimCustomer dc
LEFT JOIN 
		FactOnlineSales fos ON dc.CustomerKey = fos.CustomerKey

GROUP BY 
	CONCAT(dc.FirstName,' ',dc.LastName);

--	Count employees per DepartmentName
SELECT	
		DepartmentName,
		COUNT(EmployeeKey) AS EmployeeNumber
FROM 
	DimEmployee
GROUP BY 
		DepartmentName
ORDER BY 2 ASC;

--	Find the highest UnitPrice per ProductCategory
WITH 
	sub AS
			(SELECT 
				dpc.ProductCategoryName,
				dps.ProductSubcategoryKey

			FROM 
				DimProductCategory  dpc
			LEFT JOIN 
					DimProductSubcategory dps ON  dpc.ProductCategoryKey = dps.ProductCategoryKey		
			),
	cat AS 
			(SELECT 
				dp.ProductKey,
				--s.ProductCategoryKey,
				dp.ProductName,
				s.ProductCategoryName

			FROM 
				DimProduct dp
			LEFT JOIN 
				sub s ON dp.ProductSubcategoryKey=s.ProductSubcategoryKey)
SELECT 
	c.ProductCategoryName AS ProductCategory,
	MAX(fs.UnitPrice) AS MaxUnitPrice

FROM 
	FactSales fs
LEFT JOIN 
		cat c ON fs.ProductKey = c.ProductKey
GROUP BY 
		c.ProductCategoryName
ORDER BY 2 DESC;

-----5. Subqueries and Nested Queries-----
--	Find customers who spent more than $1000 
--(subquery on FactOnlineSales).
SELECT 
	dc.CustomerKey,
	CONCAT(dc.FirstName,' ',dc.LastName) AS FullName,
	dc.Gender,
	TotalSpend
FROM 
	DimCustomer dc
INNER JOIN
		(
		SELECT 
			CustomerKey,
			SUM(SalesAmount) AS TotalSpend
		FROM 
			FactOnlineSales
		GROUP BY 
				CustomerKey
		HAVING 
			SUM(SalesAmount)>1000
		) AS AmountSpend 
ON dc.CustomerKey = AmountSpend.CustomerKey;

--	List products never sold (NOT IN FactSales)
SELECT 
    dp.ProductKey,
    dp.ProductLabel,
    dp.ProductName
FROM 
    DimProduct dp
LEFT JOIN 
    FactOnlineSales fos ON dp.ProductKey = fos.ProductKey
WHERE 
    fos.ProductKey IS NULL;

--	Find stores with above-average SellingAreaSize.
SELECT 
	StoreKey,
	StoreName,
	SellingAreaSize
FROM 
	DimStore
WHERE 
	SellingAreaSize > (SELECT 
							AVG(SellingAreaSize) AS AverageSize
						FROM DimStore);

--	List employees earning more than their department’s average salary.
SELECT
	dc.EmployeeKey,
	dc.FirstName,
	dc.LastName,
	dc.Title,
	dc.DepartmentName,
	dc.BaseRate

FROM DimEmployee dc
JOIN
		(SELECT 
			DepartmentName,
			AVG(BaseRate) AS DeptAvgSalary
		FROM DimEmployee
		GROUP BY
			DepartmentName
		) AS DeptAvg
ON dc.DepartmentName = DeptAvg.DepartmentName
WHERE dc.BaseRate > DeptAvg.DeptAvgSalary;

--	Find promotions with the highest DiscountPercent.
SELECT 
	PromotionKey,
	PromotionLabel,
	PromotionName,
	DiscountPercent
FROM DimPromotion
WHERE
	DiscountPercent >= (SELECT MAX(DiscountPercent) FROM DimPromotion);

--	List customers who made online purchases in the last 30 days
SELECT DISTINCT
    dc.CustomerKey,
    dc.FirstName,
    dc.LastName

FROM 
    DimCustomer dc
WHERE 
    dc.CustomerKey IN (
        -- Subquery to find customers with recent purchases
        SELECT DISTINCT 
			fos.CustomerKey
        FROM 
			FactOnlineSales fos
        WHERE 
			fos.DateKey >= DATEADD(DAY, -30,'2009-12-31')
    ) AND (dc.LastName IS NOT NULL AND dc.FirstName IS NOT NULL)
ORDER BY 
	 dc.LastName, dc.FirstName;

--	Find products with inventory below safety stock (OnHandQuantity < SafetyStockQuantity).
SELECT 
    dp.ProductKey,
    dp.ProductName,
    dp.ProductLabel,
    fi.OnHandQuantity,
    fi.SafetyStockQuantity,
    (fi.SafetyStockQuantity - fi.OnHandQuantity) AS QuantityNeeded
FROM 
    DimProduct dp
JOIN 
    FactInventory fi ON dp.ProductKey = fi.ProductKey
WHERE 
    fi.OnHandQuantity < fi.SafetyStockQuantity
ORDER BY 
    QuantityNeeded DESC;

--	List outages affecting more than 5 machines.
SELECT 
    do.OutageKey,
    do.OutageName,
    do.OutageType,
    do.OutageDescription,
    COUNT(DISTINCT fis.MachineKey) AS AffectedMachinesCount
FROM 
    DimOutage do
JOIN 
    FactITSLA fis ON do.OutageKey = fis.OutageKey
GROUP BY 
    do.OutageKey,
    do.OutageName,
    do.OutageType,
    do.OutageDescription
HAVING 
    COUNT(DISTINCT fis.MachineKey) > 5
ORDER BY 
    AffectedMachinesCount DESC;

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