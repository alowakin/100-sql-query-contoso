----- Date and Time Queries---------
--	Find sales from Q1 2023 (DateKey filter).
--In Store Data
SELECT 
	SalesQuantity,
	SalesAmount,
	DATEPART(QUARTER,DateKey) as Quarter1Year2009
FROM 
	FactSales
WHERE
	DATEPART(QUARTER,DateKey) = 1 AND
	(DateKey >= '2009-01-01' AND DateKey < '2009-04-01')
	;

--In OnlineSales Data
SELECT 
	SalesQuantity,
	SalesAmount,
	CONCAT('Q',DATEPART(QUARTER,DateKey),' ', '2009') Quarter1Year2009
FROM 
	FactOnlineSales
WHERE
	DATEPART(QUARTER,DateKey) = 1 AND
	(DateKey >= '2009-01-01' AND DateKey < '2009-04-01')
;

--	List promotions active on New Year’s Day 2008.
SELECT
	PromotionLabel,
	PromotionName,
	PromotionDescription,
	DiscountPercent,
	PromotionType,
	StartDate,
	EndDate
FROM 
	DimPromotion
WHERE
	'2008-01-01' BETWEEN StartDate  AND EndDate
	AND
	(PromotionType <> 'No Discount');

--	Calculate total sales by month.
-- In store Data
SELECT
	DATEPART(month,DateKey) AS MonthOfSales,
	SUM(SalesAmount) TotalSales
FROM 
	FactSales
GROUP BY
	DATEPART(month,DateKey);

SELECT
    FORMAT(DATEFROMPARTS(2000, DATEPART(month, DateKey), 1), 'MMMM', 'en-EN') AS Mois,
    SUM(SalesAmount) AS TotalSales
FROM 
    FactSales
GROUP BY
    DATEPART(month, DateKey),
    FORMAT(DATEFROMPARTS(2000, DATEPART(month, DateKey), 1), 'MMMM', 'en-EN')
ORDER BY
    DATEPART(month, DateKey)--Order function help to sort in the appropriate order;

--	Find machines decommissioned in the last year.

SELECT 
	MachineLabel,
	MachineType,
	MachineName,
	Status,
	DecommissionDate
FROM 
	DimMachine
WHERE
	Status <> 'Used' AND
	DecommissionDate >='2015-01-01' AND DecommissionDate< '2016-01-01';

--	List holidays (HolidayName) from DimDate.
SELECT 
	HolidayName
FROM 
	DimDate
WHERE 
	HolidayName <> 'None';

--	Find employees hired on a weekend (CalendarDayOfWeek).
SELECT 
    EmployeeKey,
    FirstName,
    LastName,
    HireDate,
    DATENAME(WEEKDAY, HireDate) AS HireDayName
FROM 
    DimEmployee
WHERE 
    DATEPART(WEEKDAY, HireDate) IN (1, 7)  -- 1=Sunday, 7=Saturday (SQL Server default)
ORDER BY 
    HireDate;

--	Calculate average sales per day of the week.

SELECT
	DATENAME(WEEKDAY, DateKey) AS DayOf_Week,
	AVG(SalesAmount) AS AverageAmountOfSales
FROM
	FactSales fs
GROUP BY 
	DATENAME(WEEKDAY, DateKey)
;

--	List products discontinued (StopSaleDate) in 2023.
--Option 1
SELECT 
	ProductLabel,
	ProductName,
	ProductDescription,
	BrandName,
	StopSaleDate
FROM 
	DimProduct
WHERE
	DATEPART(YEAR, StopSaleDate) = '2008';
--Option 2
SELECT 
	ProductLabel,
	ProductName,
	ProductDescription,
	BrandName,
	StopSaleDate
FROM 
	DimProduct
WHERE
	YEAR(StopSaleDate) = '2008';

--	Find the longest outage duration per month.
SELECT
	FORMAT(DATEFROMPARTS(2000, DATEPART(month, DateKey), 1), 'MMMM', 'en-EN') AS MonthConsider,
	--do.OutageLabel,
	--do.OutageName,
	--do.OutageType,
	MAX(fit.DownTime) as OutageDuration
FROM
	FactITSLA fit
INNER JOIN
	DimOutage do ON do.OutageKey = fit.OutageKey
GROUP BY
    DATEPART(month, DateKey),
    FORMAT(DATEFROMPARTS(2000, DATEPART(month, DateKey), 1), 'MMMM', 'en-EN')
	--do.OutageLabel,
	--do.OutageName,
	--do.OutageType
ORDER BY
    DATEPART(month, DateKey)
	;

--	List customers who made their first purchase (DateFirstPurchase) in 2004.
SELECT
	CONCAT(FirstName,' ',LastName),
	EmailAddress,
	DateFirstPurchase
FROM 
	DimCustomer
WHERE
	YEAR(DateFirstPurchase) = '2004'