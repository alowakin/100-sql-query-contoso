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

---------- Aggregations (GROUP BY, SUM, AVG, etc.)------
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

----- Subqueries and Nested Queries-----
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