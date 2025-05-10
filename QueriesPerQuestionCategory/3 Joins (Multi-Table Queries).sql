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