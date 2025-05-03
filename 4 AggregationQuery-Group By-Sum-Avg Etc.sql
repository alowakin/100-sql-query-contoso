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