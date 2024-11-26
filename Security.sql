--creating database for Security Analysis project!
create database SecurityAnalysis
Use SecurityAnalysis

-- The data to be used for the security analysis project contains three tables 
-- The tables includes locations, officers and incident reports (main table) 
-- The table are structured in the manner at which each of them is created. 
-- Locations Table has 5 columns
-- Officers Table has 6 columns 
-- Incident Report table has 10 columns 

-- Creating the Locations Table
CREATE TABLE Locations (
    location_id INT PRIMARY KEY,
    neighborhood NVARCHAR(100),
    population INT,
	crime_rate DECIMAL(5, 2),
	city NVARCHAR(100)
    );

-- Creating the Officers Table
CREATE TABLE Officers (
    officerID INT PRIMARY KEY,
    name NVARCHAR(100),
    rank NVARCHAR(50),
    years_of_experience INT,
    cases_handled Int,
	location_id INT FOREIGN KEY REFERENCES Locations(location_id),
	);

-- Creating the IncidentReports Table
CREATE TABLE IncidentReports (
    incident_id INT PRIMARY KEY,
    incident_date DATE,
    location_id INT,
    incident_type NVARCHAR(50),
    severity NVARCHAR(10),
    description NVARCHAR(MAX),
    reported_by NVARCHAR(100),
    status NVARCHAR(20),
    response_time_minutes INT,
    officerID INT,
    FOREIGN KEY (location_id) REFERENCES Locations(location_id),
    FOREIGN KEY (officerID) REFERENCES Officers(officerID)
	);

-- Loading the datasets (Locations, Officers and IncidentReports)
-- Importing the datasets using Bulk Insert!
-- Loading data into Locations Table
BULK INSERT Locations
FROM 'C:\Users\HP\Documents\Security\Locations.csv' 
WITH (
    FIRSTROW = 2,           -- This skips the header row
    FIELDTERMINATOR = ',',  -- The comma serve as field separator
    ROWTERMINATOR = '\n',   -- This newline serve as row separator
    TABLOCK
);
GO

-- Loading data into Officers table
BULK INSERT Officers
FROM 'C:\Users\HP\Documents\Security\Officers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Loading data into IncidentReports table
BULK INSERT IncidentReports
FROM 'C:\Users\HP\Documents\Security\IncidentReports.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--Select * from
--Locations
--Officers,
--IncidentReports

-- Checking for missing or inconsistent data in Locations
SELECT * 
FROM Locations
WHERE neighborhood IS NULL 
   OR City IS NULL;

Select * 
From Locations
where population is Null
	or crime_rate is Null
;

-- Checking for missing or invalid data in Officers
SELECT * 
FROM Officers
WHERE name IS NULL 
   OR rank IS NULL 
   OR years_of_experience is null
   or cases_handled is null
;

-- Checking for inconsistent data and missing data in IncidentReports if any.
SELECT * 
FROM IncidentReports
WHERE incident_type IS NULL 
   OR severity NOT IN ('Low', 'Medium', 'High')
   OR status NOT IN ('Open', 'Closed', 'Pending')
   OR incident_date is null
   OR response_time_minutes is null
   ;

-- The research questions (RQ) to be answered are:
-- RQ1. What are the patterns between incidents and distribution?
-- Q1: What are the most common types of incidents reported in each location?
		-- Sub questions: what is the total number of incident by incident type
			SELECT incident_type, COUNT(*) AS total_incidents
			FROM IncidentReports
			GROUP BY incident_type
			ORDER BY total_incidents DESC
			;
		-- Incident types by location
			SELECT location_id, incident_type, COUNT(*) AS incident_count
			FROM IncidentReports
			GROUP BY location_id, incident_type
			ORDER BY incident_count DESC
			;

-- Q2: Which neighborhoods have the highest crime rates, and how do they correlate with the population size? 
-- This helps to know if higher population are susceptible to higher crime rate.
SELECT neighborhood, population, crime_rate
FROM Locations
ORDER BY crime_rate DESC
;

-- Q3: How many incidents remain unresolved in each city?
		--Sub question: how many cases remains unsolved?
		Select * 
		from IncidentReports
		where status = 'Unresolved'
		;
		-- None of the cases are unsolved, so the need to check for unsolved case by city is not applicable. 
		--SELECT L.city, COUNT(IR.status) AS unresolved_incidents
		--FROM IncidentReports IR
		--JOIN Locations L ON IR.location_id = L.location_id
		--WHERE IR.status = 'Unresolved'
		--GROUP BY L.city
		--ORDER BY unresolved_incidents DESC
		--;

-- Q4: Which city has the highest severity incidents per capita?
SELECT L.city, 
		SUM(CASE WHEN IR.severity = 'High' THEN 1 ELSE 0 END) AS high_severity_incidents,
		SUM(CASE WHEN IR.severity = 'High' THEN 1 ELSE 0 END) * 1.0 / SUM(L.population) AS incidents_per_capita
FROM IncidentReports IR
JOIN Locations L ON IR.location_id = L.location_id
GROUP BY L.city
ORDER BY incidents_per_capita DESC
;

-- Q5: What is the distribution of incidents across different days of the week?
SELECT DATENAME(WEEKDAY, incident_date) AS day_of_week, 
       COUNT(*) AS total_incidents
FROM IncidentReports
GROUP BY DATENAME(WEEKDAY, incident_date)
ORDER BY total_incidents DESC
;

-- RQ2. Is there correlation between officer performance and their experience?
-- Q6: Which officer has handled the highest number of cases?
SELECT officerID, name, cases_handled
FROM Officers
ORDER BY cases_handled DESC
;

-- Q7: What is the proportion of incidents handled by officers with more than 10 years of experience?
		-- Sub question: which officer with more than 5 years of experience handled the most case?
		SELECT * 
		FROM officers
		WHERE years_of_experience > 10
		ORDER BY cases_handled DESC
		;
		-- proportion of the cases handled (expected to be aroun 48% as the total number of officers with more than 10 years of experience is 482)
SELECT COUNT(IR.incident_id) AS incidents_handled_by_experienced, 
       (SELECT COUNT(*) FROM IncidentReports) AS total_incidents,
       COUNT(IR.incident_id) * 100.0 / (SELECT COUNT(*) FROM IncidentReports) AS percentage
FROM IncidentReports IR
JOIN Officers O ON IR.officerID = O.officerID
WHERE O.years_of_experience > 10;

-- Q8: Which officers respond the quickest on average, and does this vary by rank?
SELECT O.rank, O.name, AVG(IR.response_time_minutes) AS avg_response_time
FROM IncidentReports IR
JOIN Officers O ON IR.officerID = O.officerID
GROUP BY O.rank, O.name
ORDER BY avg_response_time ASC;
		-- the result showed that this does not vary by rank as a lieutenant had the highest and the lowest response time!
		--the question now raises is which rank had the best response time
			SELECT O.rank, AVG(IR.response_time_minutes) AS avg_response_time
			FROM IncidentReports IR
			JOIN Officers O ON IR.officerID = O.officerID
			GROUP BY O.rank
			ORDER BY avg_response_time ASC
			;

-- Q9: What is the relationship between officers' years of experience and the severity of cases they handle?
SELECT O.years_of_experience, IR.severity, COUNT(IR.incident_id) AS case_count
FROM IncidentReports IR
JOIN Officers O ON IR.officerID = O.officerID
GROUP BY O.years_of_experience, IR.severity
ORDER BY O.years_of_experience DESC, IR.severity
;


-- RQ3. What is the response times and how efficient is it?
-- Q10: What is the average response time for incidents by severity level?
SELECT severity, AVG(response_time_minutes) AS avg_response_time
FROM IncidentReports
GROUP BY severity
ORDER BY avg_response_time ASC
;

-- Q11: Do locations with higher crime rates experience longer average response times?
SELECT L.neighborhood, L.crime_rate, AVG(IR.response_time_minutes) AS avg_response_time
FROM Locations L
JOIN IncidentReports IR ON L.location_id = IR.location_id
GROUP BY L.neighborhood, L.crime_rate
ORDER BY avg_response_time DESC
;