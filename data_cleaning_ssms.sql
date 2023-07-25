-- DATA CLEANING EXERCISE--

-- FIRST LOOK AT THE DATASET --

SELECT
	*
FROM
	dbo.NashvilleHousing

-- DATE IS IN DATE TIME WHICH IN NOT NEEDED SO I WILL STANDARDISE THE DATE COLUMN TO DATE FORMAT --

--SELECT
--	SaleDate, CONVERT(DATE, SaleDate)
--FROM
--	dbo.NashvilleHousing	
--DIDN'T WORK

UPDATE
	NashvilleHousing
SET
	SaleDate = CONVERT(DATE, SaleDate) 

ALTER TABLE
	dbo.NashvilleHousing
Add SaleDateConverted DATE;

UPDATE
	NashvilleHousing
SET
	SaleDateConverted = CONVERT(DATE, SaleDate)


-- POPULATING THE PROPERTY ADDRESS COLUMN --


SELECT
	*
FROM
	dbo.NashvilleHousing
WHERE
	PropertyAddress is null--
ORDER BY
	ParcelID

SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	dbo.NashvilleHousing a
JOIN
	dbo.NashvilleHousing b
ON
	a.ParcelID = B.ParcelID
AND
	a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null 

UPDATE
	a
SET
	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	dbo.NashvilleHousing a
JOIN
	dbo.NashvilleHousing b
ON
	a.ParcelID = B.ParcelID
AND
	a.[UniqueID ] <> b.[UniqueID ]
WHERE
	a.PropertyAddress is null 	

-- BREAKING ADDRESS INTO MULTIPLE COLUMNS--

 SELECT
	PropertyAddress
FROM
	dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM
	dbo.NashvilleHousing

ALTER TABLE
	NashvilleHousing
ADD
	Address Nvarchar(255);

UPDATE
	NashvilleHousing
SET
Address = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) 

ALTER TABLE
	NashvilleHousing
ADD
	City NVARCHAR(255)

UPDATE
	NashvilleHousing
SET
	City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT 
	OwnerAddress
FROM 
	dbo.NashvilleHousing

	-- PARSENAME IS EASIER, REMEMBER TO REPLACE COMMA WITH FULL STOP --
SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) AS OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) AS State
FROM
	dbo.NashvilleHousing

ALTER TABLE
	dbo.NashvilleHousing
ADD
	OwnersAddress Nvarchar(255);

UPDATE
	dbo.NashvilleHousing
SET
	OwnersAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE
	dbo.NashvilleHousing
ADD
	OwnersCity Nvarchar(255);

UPDATE
	dbo.NashvilleHousing
SET
	OwnersCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE
	dbo.NashvilleHousing
ADD
	OwnersState Nvarchar(255);

UPDATE
	dbo.NashvilleHousing
SET
	OwnersState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


-- CHANGE Y OR N TO YES OR NO IN SOLD AS VACANT COLUMN FOR CONSISTENCY -- 

SELECT
	DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM
	dbo.NashvilleHousing
GROUP BY 
	SoldAsVacant
ORDER BY 
	2

SELECT
	SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END AS SoldAsVacantClean
FROM
	dbo.NashvilleHousing

UPDATE
	NashvilleHousing
SET
	SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant 
	END 

-- REMOVING DUPLICATES--NOT USED ON RAW DATA -- 
WITH RowNumCTE AS(
SELECT
	*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY
	UniqueID
	) row_num

FROM
	dbo.NashvilleHousing
	)

SELECT
	*
FROM
	RowNumCTE
WHERE
	row_num >1

DELETE

FROM
	RowNumCTE
WHERE
	row_num >1

-- DELETING UNUSED COLUMNS -- NOT USED ON RAW DATA --

SELECT
	*
FROM
	dbo.NashvilleHousing

ALTER TABLE
	dbo.NashvilleHousing
DROP COLUMN
	OwnersAddress, PropertyAddress, TaxDistrict, SaleDate

-- THE DATA IS NOW CLEANER, IN A MORE USABLE FORMAT AND WITH DUPLICATES AND INCONSISTENCIES REMOVED --



