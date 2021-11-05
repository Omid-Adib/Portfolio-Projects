/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


Alter table NashvilleHousing
ALTER COLUMN  saleDate Date



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

 
 select *
From [portfolio project].dbo.NashvilleHousing
where PropertyAddress is null
 
 
select a.PropertyAddress , b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
From [portfolio project].dbo.NashvilleHousing a
join  [portfolio project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [portfolio project].dbo.NashvilleHousing a
join  [portfolio project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]

select a.PropertyAddress , b.PropertyAddress 
From [portfolio project].dbo.NashvilleHousing a
join  [portfolio project].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

--   Breaking out PropertyAddress using substring method

Select PropertyAddress
From [portfolio project].dbo.NashvilleHousing


select 
SUBSTRING (propertyaddress, 1, CHARINDEX(',', PropertyAddress, 1)-1) as street, 
SUBSTRING (propertyaddress, CHARINDEX(',', PropertyAddress, 1)+1, len(propertyaddress)) as city
From [portfolio project].dbo.NashvilleHousing

Alter table NashvilleHousing
Add AddressSplitAdress nchar(255)
Alter table NashvilleHousing
Add AddressSplitCity nchar(255)

Update NashvilleHousing
set AddressSplitAdress = SUBSTRING (propertyaddress, 1, CHARINDEX(',', PropertyAddress, 1)-1)
Update NashvilleHousing
set AddressSplitCity = SUBSTRING (propertyaddress, CHARINDEX(',', PropertyAddress, 1)+1, len(propertyaddress))


select *
From [portfolio project].dbo.NashvilleHousing


--   Breaking out ownerAddress using parsename method

select
PARSENAME(replace(OwnerAddress, ',' , '.') , 3),
PARSENAME(replace(OwnerAddress, ',' , '.') , 2),
PARSENAME(replace(OwnerAddress, ',' , '.') , 1)
From [portfolio project].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);
ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select *
From [portfolio project].dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [portfolio project].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant, 
	 case	when SoldAsVacant = 'y' then 'yes'
			when SoldAsVacant = 'n' then 'no'
			ELSE SoldAsVacant
			END
From [portfolio project].dbo.NashvilleHousing
where SoldAsVacant = 'y' or SoldAsVacant = 'n'

update NashvilleHousing
set SoldAsVacant = case	when SoldAsVacant = 'y' then 'yes'
			when SoldAsVacant = 'n' then 'no'
			ELSE SoldAsVacant
			END
		

----------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

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
From [portfolio project].dbo.NashvilleHousing
)

select * 
From RowNumCTE
Where row_num > 1
--Order by  row_num desc


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From [portfolio project].dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
