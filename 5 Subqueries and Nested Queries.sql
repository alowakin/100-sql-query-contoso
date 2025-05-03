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