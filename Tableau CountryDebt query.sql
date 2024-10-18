/*
Queries used for Tableau 
CountryDebt data
*/

-- Total external debt service per country
-- This helps to understand the total debt burden
SELECT CountryCode, SUM(ExternalDebtService) AS TotalDebtService
FROM CountryDebtData
GROUP BY CountryCode
ORDER BY TotalDebtService DESC;

-- Correlating governance indicators (corruption control, government effectiveness, political stability) and debt distress.
-- since, governement effectivenes was not used in the visualization, it was expunge in the query below but was orignially part of the query
SELECT CountryCode, AVG(ControlOfCorruption) AS AvgControlOfCorruption, 
       AVG(PoliticalStability) AS AvgPoliticalStability,
       RiskOfDebtDistress
FROM CountryDebtData
GROUP BY CountryCode, RiskOfDebtDistress
ORDER BY AvgControlOfCorruption DESC;

-- Trend of Debt-to-GDP ratio to assess the debt burden relative to economic output
-- Higher ratios indicate a greater debt burden on the economy
SELECT CountryCode, Year, GDP, ExternalDebtService, 
       (ExternalDebtService / GDP) * 100 AS DebtToGDPRatio
FROM CountryDebtData
ORDER BY CountryCode, Year;