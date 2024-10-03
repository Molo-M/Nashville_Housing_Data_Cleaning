# Data Cleaning Portfolio Project: Nashville Housing Data
This project focuses on cleaning and standardizing a real-world dataset on Nashville housing transactions. The key steps include standardizing date formats, filling in missing values, breaking out addresses into individual components, standardizing categorical data, removing duplicates, and dropping unused columns.

**Skills used:** Joins, CTEs, Substring, Update, Row_Number, Case, Self-Join, SQL Functions

**Data Source:** Nashville Housing data set was downloaded from [Alex The Analyst](https://github.com/AlexTheAnalyst)'s github account. You can find the dataset here: [Nashville_Housing_Data.xlsx](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/Nashville_Housing_Data.xlsx)

## View our data:
```sql
SELECT *
FROM PortfolioProject..Nashville_Housing
```
![part 0](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part%200.PNG)

## PART 1: Standardize the Date

Create a column called SaleDateConverted where we will add our standardized date
```sql
ALTER TABLE Nashville_Housing
ADD SaleDateConverted Date
```

![Part 1](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_1_1.PNG)

Populate the new column with our standardized data
```sql
UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(DATE, SaleDate)
```
![Part 1](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_1_2.PNG)

View the results
```sql
SELECT SaleDateConverted, SaleDate
FROM PortfolioProject..Nashville_Housing
```
![Part 1](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_1_3.PNG)


## PART 2: Populate Property Address Data

View the "PropertyAddress" column 
```sql
SELECT PropertyAddress
FROM PortfolioProject..Nashville_Housing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID
```
![Part 2](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_2_1.PNG)

The null "PropertyAddress" values are supposed have the same "ParcelID" as some other non-Null values
We will use a self-join to see this and populate the NULL values later
```sql
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing a
JOIN PortfolioProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
```
![Part 2](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_2_2.PNG)

Populate the NULL values
```sql
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville_Housing a
JOIN PortfolioProject..Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
```
![Part 2](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_2_3.PNG)

## PART 3: Breaking Out Address Into Individual Columns (Address, City, State)


View the data
```sql
SELECT PropertyAddress
FROM PortfolioProject..Nashville_Housing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_1.PNG)


Use "SUBSTRING" to split the "PropertyAddress" and view the results.

**NOTE:** No changes are made to the data. This is only for viewing. The changes are made in the next code.
```sql
SELECT PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address_2
FROM PortfolioProject..Nashville_Housing
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_2.PNG)

Create new column "PropertySplitAddress" and populate with the split data
```sql
ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_3.PNG)

```sql
UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_4.PNG)


Create new column "PropertySplitCity" and populate with the split data
```sql
ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_5.PNG)

```sql
UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_6.PNG)

View the results
```sql
SELECT *
FROM PortfolioProject..Nashville_Housing
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_7.PNG)

Next, we are going to do the same for the "OwnerAddress" column.
```sql
SELECT OwnerAddress
FROM PortfolioProject..Nashville_Housing
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_8.PNG)

Use "PARSENAME" to split the "OwnerAddress" and view the results.

**NOTE:** No changes are made to the data. This is only for viewing. The changes are made in the next code.
```sql
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM PortfolioProject..Nashville_Housing
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_9.PNG)


Create Owner Address Column and populate it with the results:
```sql
ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_10.PNG)

```sql
UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_11.PNG)


Create Owner City Column and populate it with the results:
```sql
ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_12.PNG)

```sql
UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_13.PNG)


Create Owner State Column and populate it with the results:
```sql
ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_14.PNG)

```sql
UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_15.PNG)

View the results
```sql
SELECT *
FROM PortfolioProject..Nashville_Housing
```
![Part 3](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_3_16.PNG)


## PART 4: Change Y and N to Yes and No in "Sold as Vacant" field

View the number of different Yes and No in the column
We can see that there is both "Y" and "Yes". There is also both "N" and "No". This is what we must change.
```sql
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2
```
![Part 4](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_4_1.PNG)


Use "CASE" to see how the changes would occur
```sql
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject..Nashville_Housing
```
![Part 4](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_4_2.PNG)

Apply the changes
```sql
UPDATE Nashville_Housing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
```
![Part 4](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_4_3.PNG)

## PART 5: Remove duplicates

We will use "ROW_NUMBER" to do this
```sql
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
```
![Part 5](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_5_1.PNG)


View the results
```sql
SELECT *
FROM PortfolioProject..Nashville_Housing
```
![Part 5](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_5_2.PNG)


## PART 6: Delete Unused Columns


View the data
```sql
SELECT *
FROM PortfolioProject..Nashville_Housing
```
![Part 6](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_6_1.PNG)


Drop OwnerAddress, TaxDistrict, PropertyAddress because we already created columns with their split data
```sql
ALTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
```
![Part 6](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_6_2.PNG)

We also dropped SaleDate because we created a standardized date column for it earlier
```sql
ALTER TABLE PortfolioProject..Nashville_Housing
DROP COLUMN SaleDate
```
![Part 6](https://github.com/Molo-M/Nashville_Housing_Data_Cleaning/blob/main/sql_images/Part_6_3.PNG)


# Thank You!
