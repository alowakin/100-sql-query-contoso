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