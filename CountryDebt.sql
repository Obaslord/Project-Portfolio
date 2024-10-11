-- Creating the database to store debt data
CREATE DATABASE newdebt_data;

-- Selecting the newly created database to use
USE newdebt_data;

-- The data to be used was obtained from Kaggle (available at: https://www.kaggle.com/datasets/evadrichter/evolution-of-debt-distress-in-hipc-countries/data)
-- The dataset description is tagged as Risk of external debt distress, according to the Debt Sustainability Analysis (DSA) for Low-Income countries conducted jointly by the International Monetary Fund (IMF) and World Bank.
-- The description for each variable is highlighted as:
-- CountryCode: Three-letter country code (e.g., CMR)
-- Year: Year of the data (range 2005-2019)
-- RiskOfDebtDistress: Qualitative measure of debt distress ('High', 'In debt distress', 'Medium', 'Low')
-- DebtIndicator: Numeric indicator of debt distress (e.g., 1 for high risk, 0 for no risk)
-- Inflation: Inflation rate (percentage) in the country
-- CurrentAccountBalance: Current account balance (in millions of USD)
-- GeneralGovLendingBorrowing: Government lending/borrowing balance (in millions of USD)
-- VolumeExportGoods: Value of exported goods (in millions of USD)
-- GDP: Gross Domestic Product (in billions of USD)
-- GDPPerCapita: GDP per capita (in USD)
-- GeneralGovRenue: Total government revenue (in millions of USD)
-- USInterestRates: US interest rate (affecting global debt servicing)
-- ExternalDebtService: Debt service payments (in millions of USD)
-- RealGDPGrowth: Real GDP growth rate (percentage)
-- ExchangeRate: Exchange rate relative to USD
-- ControlOfCorruption: Governance indicator (scale 0-10, with 10 being no corruption)
-- GovernmentEffectiveness: Governance effectiveness (scale 0-10)
-- PoliticalStability: Political stability (scale 0-10)
-- RegulatoryQuality: Quality of regulation (scale 0-10)
-- RuleOfLaw: Strength of the legal system (scale 0-10)
-- VoiceAndAccountability: Extent of citizens' political rights and liberties (scale 0-10)

CREATE TABLE CountryDebtData (
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

-- Verifying the table structure
SELECT * FROM CountryDebtData;

-- Importing data into the table from a CSV file after cleaning the data in Excel
-- BULK INSERT allows for importing large datasets quickly
-- FIELDTERMINATOR specifies the delimiter between columns (commas in this case)
-- ROWTERMINATOR specifies the end of each row (newline characters)
-- FIRSTROW skips the header row of the CSV

BULK INSERT CountryDebtData
FROM 'C:\Users\HP\Downloads\LICDebt.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- After realizing an issue with the ControlOfCorruption column's data type, 
-- we alter it to increase precision for better accuracy
ALTER TABLE CountryDebtData
ALTER COLUMN ControlOfCorruption DECIMAL(10,2);

-- Re-importing data into the table after correcting the column definition
BULK INSERT CountryDebtData
FROM 'C:\Users\HP\Downloads\LICDebt.csv'
WITH (
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);

-- Previewing the data after the import is successful
SELECT * FROM CountryDebtData;

-- Query 1: Fetching countries with the highest debt distress level ('High') sorted by year
-- This query shows the trend of high debt distress across countries over time
SELECT CountryCode, Year, RiskOfDebtDistress
FROM CountryDebtData
WHERE RiskOfDebtDistress = 'High'
ORDER BY Year ASC;

-- Query 2: Calculating total external debt service per country
-- This helps to understand the total debt burden
SELECT CountryCode, SUM(ExternalDebtService) AS TotalDebtService
FROM CountryDebtData
GROUP BY CountryCode
ORDER BY TotalDebtService DESC;

-- Query 3: Finding countries with the lowest GDP per capita and the highest debt distress
-- Using the average GDP per capita as the threshold
SELECT AVG(GDPPerCapita) AS AVGGDPPerCapita
FROM CountryDebtData;

-- Based on the average GDP per capita (909.689198), we fetch countries below this value and with 'High' debt distress
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < 909.689198 AND RiskOfDebtDistress = 'High'
ORDER BY CountryCode ASC;

-- Alternatively, ordering the results by GDP per capita for better clarity
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < 909.689198 AND RiskOfDebtDistress = 'High'
ORDER BY GDPPerCapita ASC;

-- Performing the same query using a subquery to calculate the average simultaneously
SELECT CountryCode, Year, GDPPerCapita, RiskOfDebtDistress
FROM CountryDebtData
WHERE GDPPerCapita < (
    SELECT AVG(GDPPerCapita)
    FROM CountryDebtData
)
AND RiskOfDebtDistress = 'High'
ORDER BY GDPPerCapita ASC;

-- Query 4: Correlating governance indicators (corruption control, government effectiveness, political stability) with debt distress. Higher values indicate better governance. 
SELECT CountryCode, AVG(ControlOfCorruption) AS AvgControlOfCorruption, 
       AVG(GovernmentEffectiveness) AS AvgGovEffectiveness, 
       AVG(PoliticalStability) AS AvgPoliticalStability,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgControlOfCorruption DESC;

-- Query 5: Tracking the change in external debt service from the previous year
-- Using the LAG function to fetch the previous year's debt service data for each country
-- DebtChange calculates the difference between current and previous year debt service
SELECT CountryCode, Year, ExternalDebtService,
       LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS PreviousYearDebtService,
       ExternalDebtService - LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS DebtChange
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- Query 6: Calculating the Debt-to-GDP ratio to assess the debt burden relative to economic output
-- Higher ratios indicate a greater debt burden on the economy
SELECT CountryCode, Year, GDP, ExternalDebtService, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- Query 7: Assessing the long-term sustainability of debt levels by country
-- Debt-to-GDP, Debt-to-Exports, and Debt-to-Revenue ratios provide insights into the sustainability of debt burdens
SELECT CountryCode, Year, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio,
       (ExternalDebtService / VolumeExportGoods) * 100 AS DebtServiceToExports,
       (ExternalDebtService / GeneralGovLendingBorrowing) * 100 AS DebtServiceToRevenue
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- Query 8: Analyzing debt growth trends over time by calculating the annual percentage growth in external debt
SELECT CountryCode, Year, 
       ExternalDebtService, 
       LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) AS PreviousYearDebt,
       (ExternalDebtService - LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year)) / LAG(ExternalDebtService, 1) OVER (PARTITION BY CountryCode ORDER BY Year) * 100 AS DebtGrowthPercentage
FROM CountryDebtData
ORDER BY CountryCode, Year;

-- Query 9: Examining the relationship between inflation, GDP growth, and debt levels by averaging economic indicators
-- over time and comparing them across debt distress categories
SELECT CountryCode, 
       AVG(Inflation) AS AvgInflation, 
       AVG(RealGDPGrowth) AS AvgGDPGrowth, 
       AVG(ExternalDebtService / GDP) * 100 AS AvgDebtToGDPRatio,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgDebtToGDPRatio DESC;

-- Query 10: Investigating how external factors, specifically US interest rates, affect debt servicing costs
SELECT CountryCode, Year, 
       USInterestRates, 
       ExternalDebtService, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio
FROM CountryDebtData
ORDER BY USInterestRates DESC, Year ASC;

-- Query 11: Investigating if poor governance, political instability, and or corruption have a link with high debt distress?
SELECT CountryCode, AVG(ControlOfCorruption) AS AvgCorruptionControl, 
       AVG(PoliticalStability) AS AvgPoliticalStability, 
       AVG(GovernmentEffectiveness) AS AvgGovEffectiveness,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgCorruptionControl DESC;

-- Query 12: Identifying what countries are at high risk of defaulting, and that may need debt restructuring 
SELECT CountryCode, Year, 
       (CASE 
          WHEN (ExternalDebtService / GDP) * 100 > 50 THEN 'High Risk'
          WHEN (ExternalDebtService / GDP) * 100 BETWEEN 30 AND 50 THEN 'Medium Risk'
          ELSE 'Low Risk'
       END) AS DefaultRiskCategory
FROM CountryDebtData
ORDER BY Year, DefaultRiskCategory DESC;
