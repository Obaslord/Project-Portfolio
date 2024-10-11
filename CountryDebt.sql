-- creating the databae to house the debt data table
create DATABASE newdebt_data

-- Using the database created
use newdebt_data

-- creating the table variables
CREATE TABLE CountryDebtData1 (
    CountryCode VARCHAR(3),
    Year INT,
    RiskOfDebtDistress VARCHAR(50),
    DebtIndicator INT,
    Inflation DECIMAL(5,2),
    CurrentAccountBalance DECIMAL(10,2),
    GeneralGovLendingBorrowing DECIMAL(10,2),
    VolumeExportGoods DECIMAL(10,2),
    GDP DECIMAL(10,2),
    GDPPerCapita DECIMAL(10,2),
	GeneralGovRenue DECIMAL(10,2),
    USInterestRates DECIMAL(5,2),
    ExternalDebtService DECIMAL(15,2),
    RealGDPGrowth DECIMAL(5,2),
    ExchangeRate DECIMAL(10,2),
    ControlOfCorruption DECIMAL(10,2),
    GovernmentEffectiveness DECIMAL(5,2),
    PoliticalStability DECIMAL(5,2),
    RegulatoryQuality DECIMAL(5,2),
    RuleOfLaw DECIMAL(5,2),
    VoiceAndAccountability DECIMAL(5,2)
);
-- Checking the table
Select * from CountryDebtData

-- Importing data
-- using bulkinsert after cleaning the data in excel
BULK INSERT CountryDebtData
FROM 'C:\Users\HP\Downloads\LICDebt.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Notice an error with one of the variable (ControlOfCorruption) and altering the data to fit using alter command
ALTER TABLE CountryDebtData
ALTER COLUMN ControlOfCorruption DECIMAL(10,2);

-- Using the bulkinsert again
BULK INSERT CountryDebtData
FROM 'C:\Users\HP\Downloads\LICDebt.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- After it was succesful, the table was previewed
Select * from CountryDebtData

-- Running queries
-- 1. Country with highest debt stress
SELECT CountryCode, Year, RiskOfDebtDistress
FROM CountryDebtData
WHERE RiskOfDebtDistress = 'High'
ORDER BY Year ASC;

-- 2. Total external debt service by country
SELECT CountryCode, SUM(ExternalDebtService) AS TotalDebtService
FROM CountryDebtData
GROUP BY CountryCode
ORDER BY TotalDebtService DESC;

-- 3. Countriews with lowest GDP per capita and highest debt distress
-- I want to use the average as the criteria, hence i will first find average
Select AVG(GDPPerCapita) as AVGGDPPerCapita
From CountryDebtData

-- average is 909.689198, i will use this as criteria!
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < 909.689198 AND RiskOfDebtDistress = 'High'
ORDER BY CountryCode ASC;

-- or one copuld order it by GDPPerCapita
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < 909.689198 AND RiskOfDebtDistress = 'High'
ORDER BY GDPPerCapita ASC;

-- one can also run the query directly by using subquery for average as below
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < (
Select AVG(GDPPerCapita)
from CountryDebtData
)
AND RiskOfDebtDistress = 'High'
ORDER BY GDPPerCapita ASC;

-- 4. Correlation between governance indicator and debt distress
SELECT CountryCode, AVG(ControlOfCorruption) AS AvgControlOfCorruption, 
       AVG(GovernmentEffectiveness) AS AvgGovEffectiveness, 
       AVG(PoliticalStability) AS AvgPoliticalStability,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgControlOfCorruption DESC;

-- 5. Tracking debt data
SELECT CountryCode, Year, ExternalDebtService,
       LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS PreviousYearDebtService,
       ExternalDebtService - LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS DebtChange
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- 6. Relationship between GDP and Debt service
SELECT CountryCode, Year, GDP, ExternalDebtService, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- 7. Long term sustainability of debt level by country
SELECT CountryCode, Year, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio,
       (ExternalDebtService / VolumeExportGoods) * 100 AS DebtServiceToExports,
       (ExternalDebtService / GeneralGovLendingBorrowing) * 100 AS DebtServiceToRevenue
FROM CountryDebtData
ORDER BY CountryCode, Year;

--8. Debt growth trend. This provides an understanding of how debt burdens have evolved over the years
SELECT CountryCode, Year, 
       ExternalDebtService, 
       LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS PreviousYearDebt,
       (ExternalDebtService - LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year)) / LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) * 100 AS DebtGrowthPercentage
FROM CountryDebtData
ORDER BY CountryCode, Year;

--9. Debt vulnerabilities and economic indicators
SELECT CountryCode, 
       AVG(Inflation) AS AvgInflation, 
       AVG(RealGDPGrowth) AS AvgGDPGrowth, 
       AVG(ExternalDebtService / GDP) * 100 AS AvgDebtToGDPRatio,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgDebtToGDPRatio DESC;

-- 10. how does external facor (such as US interest rate) affect the debt servicing 
SELECT CountryCode, Year, 
       USInterestRates, 
       ExternalDebtService, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio
FROM CountryDebtData
WHERE USInterestRates IS NOT NULL
ORDER BY Year;

--11. does poor governance, political instability and or cooruption have link with high debt distress?
SELECT CountryCode, AVG(ControlOfCorruption) AS AvgCorruptionControl, 
       AVG(PoliticalStability) AS AvgPoliticalStability, 
       AVG(GovernmentEffectiveness) AS AvgGovEffectiveness,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgCorruptionControl DESC;

--12. what countries are in high risk of defaulting, and that may need debt restructuring 
SELECT CountryCode, Year, 
       (CASE 
          WHEN (ExternalDebtService / GDP) * 100 > 50 THEN 'High Risk'
          WHEN (ExternalDebtService / GDP) * 100 BETWEEN 30 AND 50 THEN 'Medium Risk'
          ELSE 'Low Risk'
       END) AS DefaultRiskCategory
FROM CountryDebtData
ORDER BY Year, DefaultRiskCategory DESC;
