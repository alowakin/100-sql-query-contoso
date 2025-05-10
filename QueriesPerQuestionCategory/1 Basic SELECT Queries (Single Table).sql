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