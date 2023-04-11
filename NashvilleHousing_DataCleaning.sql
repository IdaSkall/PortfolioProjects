/*Cleaning Data 

The NashvilleHousing table is due for a data cleaning. Among other things, the table contains attributes that consists of multiple values
such as PropertyAddress, which contains both address and city, and that is something that we want to aviod. 

Every attribute should only be responsible for one value. 
*/



------------------------
-- Standardize Date format: removing time format as it serves no purpose to the table.

Select SaleDateConverted, Convert(Date, SaleDate) 
From PortfolioProject.dbo.NashVilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)



------------------------
-- Populate Property Address Data.  


Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.ParcelID)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.ParcelID)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



------------------------
-- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
   TRIM(CASE 
         WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 
         ELSE PropertyAddress 
      END) AS Address1, 
   TRIM(CASE 
         WHEN CHARINDEX(',', PropertyAddress) > 0 
         THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 
         ELSE '' 
      END) AS Address2 
FROM PortfolioProject.dbo.NashvilleHousing


-- Add PropertySplitAddress column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


-- Update PropertySplitAddress column with the address part before the comma
UPDATE NashvilleHousing
SET PropertySplitAddress = TRIM(CASE 
                                    WHEN CHARINDEX(',', PropertyAddress) > 0 
                                    THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
                                    ELSE PropertyAddress 
                                END);

-- Add PropertySplitCity column to NashvilleHousing table
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


-- Update PropertySplitCity column with the address part after the comma
UPDATE NashvilleHousing
SET PropertySplitCity = TRIM(CASE 
                                WHEN CHARINDEX(',', PropertyAddress) > 0 
                                THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 
                                ELSE '' 
                            END);


-- OwnerAddress currently displays address, city, and the state, and we need to split those out.
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)



------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing



------------------------
-- Remove Duplicates (using a CTE)

WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--Order By ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
