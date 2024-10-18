-- Create a new database named AI_Rise
create database AI_Rise;

-- Create a table AI_Adoption with columns for various AI-related metrics (like revenue, market value, job impacts, etc.)
CREATE TABLE AI_Adoption (
    Year INT,  -- Year of data
    AI_Software_Revenue DECIMAL(10, 2),  -- Revenue from AI software in billions
    Global_AI_Market_Value DECIMAL(10, 2),  -- Value of the global AI market in billions
    AI_Adoption_Percentage DECIMAL(5, 3),  -- Percentage of global organizations adopting AI
    Organizations_Using_AI DECIMAL(5, 3),  -- Percentage of organizations currently using AI
    Organizations_Planning_to_Implement_AI DECIMAL(5, 3),  -- Percentage of organizations planning to implement AI
    Global_Expectation_for_AI_Adoption DECIMAL(5, 3),  -- Percentage of global expectation for AI adoption
    Estimated_Jobs_Eliminated_By_AI DECIMAL(5, 3),  -- Estimated number of jobs eliminated by AI (in millions)
    Estimated_New_Jobs_Created_By_AI DECIMAL(5, 3),  -- Estimated new jobs created due to AI (in millions)
    Net_Job_Loss_in_US DECIMAL(5, 3),  -- Net job loss in the US due to AI (in millions)
    Organizations_Believing_AI_Provides_Competitive_Edge DECIMAL(5, 3),  -- Percentage of organizations believing AI gives a competitive advantage
    Companies_Prioritizing_AI DECIMAL(5, 3),  -- Percentage of companies prioritizing AI in business strategy
    Estimated_Revenue_Increase_from_AI DECIMAL(10, 2),  -- Estimated revenue increase due to AI adoption (in billions)
    Marketers_Believing_AI_Improves_Email_Revenue DECIMAL(5, 3),  -- Percentage of marketers believing AI boosts email revenue
    Expected_Increase_in_Employee_Productivity DECIMAL(5, 3),  -- Expected percentage increase in employee productivity due to AI
    Americans_Using_Voice_Assistants DECIMAL(5, 3),  -- Percentage of Americans using voice assistants
    Digital_Voice_Assistants_Billions DECIMAL(5, 3),  -- Number of digital voice assistants in billions
    Medical_Professionals_Using_AI_for_Diagnosis DECIMAL(5, 3),  -- Percentage of medical professionals using AI for diagnosis
    AI_Contribution_to_Healthcare DECIMAL(10, 2),  -- Contribution of AI to the healthcare industry in billions
    Jobs_High_Risk_Transportation DECIMAL(5, 3),  -- Percentage of high-risk jobs in transportation due to AI automation
    Jobs_High_Risk_Wholesale_Retail DECIMAL(5, 3),  -- Percentage of high-risk jobs in wholesale and retail due to AI automation
    Jobs_High_Risk_Manufacturing DECIMAL(5, 3)  -- Percentage of high-risk jobs in manufacturing due to AI automation
);

-- Manual insert of data from 2018 to 2025
Insert into AI_Adoption values
(2018, 10.1, 29.5, 0.10, 0.35, 0.40, 0.40, 0.10, 0.05, 0.07, 0.87, 0.83, 1.2, 0.4129, 0.05, 0.20, 1.5, 0.38, 461, 0.35, 0.44, 0.4640),
(2019, 14.69, 35, 0.20, 0.37, 0.42, 0.47, 0.15, 0.08, 0.065, 0.88, 0.84, 1.8, 0.42, 0.07, 0.25, 2, 0.39, 465, 0.38, 0.45, 0.47),
(2020, 22.59, 45, 0.30, 0.40, 0.45, 0.54, 0.20, 0.12, 0.06, 0.88, 0.85, 2.4, 0.43, 0.09, 0.30, 2.6, 0.41, 470, 0.40, 0.46, 0.4750),
(2021, 34.87, 65, 0.35, 0.42, 0.47, 0.61, 0.25, 0.16, 0.055, 0.89, 0.86, 3, 0.44, 0.11, 0.35, 3.2, 0.43, 475, 0.43, 0.47, 0.48),
(2022, 51.27, 140, 0.35, 0.45, 0.50, 0.68, 0.30, 0.20, 0.05, 0.90, 0.87, 3.6, 0.45, 0.13, 0.40, 3.8, 0.45, 480, 0.45, 0.48, 0.4850),
(2023, 70.94, 279, 0.35, 0.48, 0.53, 0.73, 0.35, 0.24, 0.048, 0.91, 0.88, 4.2, 0.46, 0.15, 0.45, 4.4, 0.47, 485, 0.48, 0.49, 0.49),
(2024, 94.41, 400, 0.40, 0.50, 0.55, 0.78, 0.40, 0.28, 0.045, 0.92, 0.89, 4.8, 0.47, 0.18, 0.50, 5, 0.48, 490, 0.50, 0.50, 0.4950),
(2025, 126, 1810, 0.63, 0.55, 0.58, 0.82, 0.45, 0.32, 0.042, 0.93, 0.90, 5.5, 0.48, 0.20, 0.55, 5.5, 0.50, 500, 0.52, 0.51, 0.50);

Select * from AI_Adoption;

-- Query 1: Calculate AI software revenue growth percentage year-over-year
-- Using LAG to find the revenue from the previous year and then calculate the percentage growth compared to the previous year.
SELECT Year, "AI Software Revenue", 
LAG("AI Software Revenue", 1) OVER (ORDER BY Year) AS Previous_Year_Revenue,
(("AI Software Revenue" - LAG("AI Software Revenue", 1) OVER (ORDER BY Year)) / 
LAG("AI Software Revenue", 1) OVER (ORDER BY Year)) * 100 AS Revenue_Growth_Percentage
FROM AI_Data;

-- Query 2: Retrieve AI adoption percentage by year, to understand the trend of AI adoption from 2018 to 2025
select Year, AI_Adoption_Percentage
from AI_Adoption
Order by Year ASC;

-- Query 3: Retrieve AI software revenue and global AI market value by year, to observe both revenue and market value growth trends over time
select Year, AI_Software_Revenue, Global_AI_Market_Value
from AI_Adoption
Order by Year ASC;

-- Query 4: Retrieve the estimated number of jobs eliminated and created by AI, to track how job dynamics are shifting from 2018 to 2025
select Year, Estimated_Jobs_Eliminated_By_AI, Estimated_New_Jobs_Created_By_AI
from AI_Adoption
Order by Year ASC;

-- Query 5: Retrieve job data specifically for the US, showing the net job loss and its correlation with estimated jobs eliminated and created by AI
select Year, Net_Job_Loss_in_US, Estimated_Jobs_Eliminated_By_AI, Estimated_New_Jobs_Created_By_AI
from AI_Adoption
where Net_Job_Loss_in_US is not null 
Order by Year ASC;

-- Query 6: Analyze how AI is viewed by organizations, by retrieving data on the percentage of companies believing AI provides a competitive edge and those prioritizing AI in their strategies
select Year, Organizations_Believing_AI_Provides_Competitive_Edge, Companies_Prioritizing_AI
from AI_Adoption
Order by Year ASC;

-- Query 7: Focus on 2025 to identify high-risk sectors (transportation, wholesale/retail, and manufacturing) that are most vulnerable to AI-driven automation
select Year, Jobs_High_Risk_Transportation, Jobs_High_Risk_Wholesale_Retail, Jobs_High_Risk_Manufacturing
from AI_Adoption
where Year = 2025;
