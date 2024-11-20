-- Data Cleaning project in sql 

-- Creating the database

use housing

-- creating Table Nashville Housing Data as NHD
create table NHD (
    UniqueID INT,                     -- Unique identifier
    ParcelID VARCHAR(50),             -- combination of numbers and strings
    LandUse VARCHAR(50),              -- Description of the land use type (e.g., Residential, Commercial)
    PropertyAddress VARCHAR(255),     -- Full property address including number and street
    SaleDate DATE,                    -- Date of sale in YYYY-MM-DD format
    SalePrice DECIMAL(15, 2),         -- numeric value with two decimal places
    LegalReference VARCHAR(50),       -- alphanumeric string (Expeted to be unique too, if duplicates are not available)
    SoldAsVacant VARCHAR(3),          -- Indicates if sold as vacant property ('Yes' or 'No')
    OwnerName VARCHAR(255),           -- Full name of the property owner
    OwnerAddress VARCHAR(255),        -- Complete address of the property owner
    Acreage DECIMAL(10, 2),           -- Size of the property in acres
    TaxDistrict VARCHAR(50),          -- Tax district information (e.g., county or jurisdiction)
    LandValue DECIMAL(15, 2),         -- Value assigned to the land
    BuildingValue DECIMAL(15, 2),     -- Value of the building structure
    TotalValue DECIMAL(15, 2),        -- Total property value (land + building)
    YearBuilt INT,                    -- Construction year of the property
    Bedrooms INT,                     -- Number of bedrooms in the property
    FullBath INT,                     -- Number of full bathrooms
    HalfBath INT                      -- Number of half bathrooms
)

BULK INSERT NHD																-- using bulk Insert to load data
FROM "C:\Users\HP\Downloads\Nashville Housing Data for Data Cleaning.csv"	-- Importing data from local path
WITH (
    FORMAT = 'CSV',															-- Data format (Comma Seperated)
    FIELDTERMINATOR = ',',													-- Specifies the delimiter between columns (commas in this case)
    ROWTERMINATOR = '\n',													-- Specifies the end of each row (newline characters)
    FIRSTROW = 2															-- Skips the header row of the CSV
);

-- There was error with some columns under SALEPRICE some were formatted in Naira and date. I opened the excel and reformat the saleprice column to general and re-run the bulk-Insert

-- Previewing the table structure after import is succesful!
Select * from NHD

-- Populating the property address 
Select propertyaddress 
from NHD
where propertyaddress is null

Select *
from NHD
order by ParcelID

-- Theres a pattern between parcelID and propertyaddress as some of them have same parcelID, so we can use this to populate the propertyaddress that are null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NHD a
Join NHD b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Updating the PropertAddress to get rid of the null
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NHD a
Join NHD b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Breaking out PropertyAddress into individual column
 Select
 SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress ) -1) as Address
 -- From NHD
 , SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress ) +1, LEN(PropertyAddress)) as Address
 from NHD

 -- Altering the for updating the "Splits"
Alter Table NHD
Add PropertySplitAddress Nvarchar(255);

 Update NHD
 set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress ) -1)
 
Alter Table NHD
Add PropertySplitCity Nvarchar(50);

  Update NHD
 set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress ) +1, LEN(PropertyAddress))

  -- Using PARSENAME to split the owneraddress instead of substring
 Select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 from NHD

 --altering and updating table
 Alter table NHD
 add OwnerSplitAddress Nvarchar(255);
 Alter table NHD
 add OwnerSplitCity Nvarchar(255);
 Alter table NHD
 add OwnerSplitState Nvarchar(255);

 update NHD
 set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 update NHD
 set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
 update NHD
 set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

 -- Editing soldasvacant due to inconsistency in respresentation of Yes and No's
 select distinct(soldasvacant)
 from NHD

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from NHD

update NHD
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

-- Removing duplicates 
with RowNumCTE as(
select *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) as row_num
from NHD
)
Delete
from RowNumCTE
where row_num > 1


-- Deletng unused column (Specifically, column that was splitted)
alter table NHD
Drop column PropertyAddress, OwnerAddress