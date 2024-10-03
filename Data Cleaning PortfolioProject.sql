
-- Data Cleaning Portfolio Project: Nashville Housing Data
-- This project focuses on cleaning and standardizing a real-world dataset on Nashville housing transactions.


--View our data:
SELECT *
FROM PortfolioProject..Nashville_Housing

--PART 1
--Standardize the Date

--Create a column called SaleDateConverted where we will add our standardized date
ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date

--Populate the new column with our standardized data
UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--View the results
SELECT SaleDateConverted, SaleDate
FROM PortfolioProject..Nashville_Housing


--PART 2
--Populate Property Address Data

--View the "PropertyAddress" column 
SELECT PropertyAddress
FROM PortfolioProject..Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--The null "PropertyAddress" values are supposed have the same "ParcelID" as some other non-Null values
--We will use a self-join to see this and populate the NULL values later
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing a
JOIN PortfolioProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Populate the NULL values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing a
JOIN PortfolioProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--PART 3
--Breaking Out Address Into Individual Columns (Address, City, State)


--View the data
SELECT PropertyAddress
FROM PortfolioProject..Nashville_Housing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID


--Use "SUBSTRING" to split the "PropertyAddress" and view the results.
--NOTE: No changes are made to the data. This is only for viewing. The changes are made in the next code.
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address_2
FROM PortfolioProject..Nashville_Housing

--Create new column "PropertySplitAddress" and populate with the split data
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


--Create new column "PropertySplitCity" and populate with the split data
ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255)

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--View the results
SELECT *
FROM PortfolioProject..Nashville_Housing

--Next, we are going to do the same for the "OwnerAddress" column.
SELECT OwnerAddress
FROM PortfolioProject..Nashville_Housing

--Use "PARSENAME" to split the "OwnerAddress" and view the results.
--NOTE: No changes are made to the data. This is only for viewing. The changes are made in the next code.
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM PortfolioProject..Nashville_Housing


--Create Owner Address Column and populate it with the results:
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


--Create Owner City Column and populate it with the results:
ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


--Create Owner State Column and populate it with the results:
ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255)

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--View the results
SELECT *
FROM PortfolioProject..Nashville_Housing


--PART 4
--Change Y and N to Yes and No in "Sold as Vacant" field:

--View the number of different Yes and No in the column
--We can see that there is both "Y" and "Yes". There is also both "N" and "No". This is what we must change.
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2


--Use "CASE" to see how the changes would occur
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..Nashville_Housing

--Apply the changes
UPDATE Nashville_Housing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END

--PART 5:
--Remove duplicates

--We will use "ROW_NUMBER" to do this
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject..Nashville_Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--View the results
SELECT *
FROM PortfolioProject..Nashville_Housing


--PART 6
--Delete Unused Columns:

--View the data
SELECT *
FROM PortfolioProject..Nashville_Housing


--Drop OwnerAddress, TaxDistrict, PropertyAddress because we already created columns with their split data
ALTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--We also dropped SaleDate because we created a standardized date column for it earlier
ALTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN SaleDate
