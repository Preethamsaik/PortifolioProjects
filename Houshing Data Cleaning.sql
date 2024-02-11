/*

Cleaning Data in SQL

*/


-- Select all records from NashvilleHousing table

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

-- Display saleDateConverted and the converted SaleDate
Select saleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing

-- Update SaleDate column with the converted SaleDate
Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- If the update doesn't work properly, add a new column SaleDateConverted and update it
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- Display all records from NashvilleHousing
-- Order by ParcelID
Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- Update PropertyAddress where it is null with the non-null value from another record with the same ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Display PropertyAddress from NashvilleHousing
-- SELECT the address and city from PropertyAddress
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing

-- Add columns PropertySplitAddress and PropertySplitCity to NashvilleHousing
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

-- Update PropertySplitAddress with the extracted address
Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- Add column PropertySplitCity to NashvilleHousing
ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

-- Update PropertySplitCity with the extracted city
Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

-- Display all records from NashvilleHousing
Select *
From NashvilleHousing

-- Display OwnerAddress from NashvilleHousing
Select OwnerAddress
From NashvilleHousing

-- Display parsed OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState from OwnerAddress
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as OwnerSplitState
From NashvilleHousing

-- Add columns OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState to NashvilleHousing
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

-- Update OwnerSplitAddress with the parsed address
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- Add columns OwnerSplitCity and OwnerSplitState to NashvilleHousing
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

-- Update OwnerSplitCity with the parsed city
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- Add column OwnerSplitState to NashvilleHousing
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

-- Update OwnerSplitState with the parsed state
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Display all records from NashvilleHousing
Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Display distinct SoldAsVacant values and their counts
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

-- Change Y and N to Yes and No in SoldAsVacant column
Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

-- Update SoldAsVacant column with Yes and No values
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Create a Common Table Expression (CTE) with row numbers partitioned by certain columns
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
From NashvilleHousing
--order by ParcelID
)
-- Select records with row numbers greater than 1 (indicating duplicates)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Display all records from NashvilleHousing
Select *
From NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

-- Display all records from NashvilleHousing
Select *
From NashvilleHousing

-- Remove specified columns from NashvilleHousing table
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















