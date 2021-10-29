Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

Select * 
From PortfolioProject..NashvilleHousing


--Populate Property Address where is null, looking where the parcelid is the same 

Select n.ParcelID, n.PropertyAddress, na.ParcelID, na.PropertyAddress, ISNULL(n.PropertyAddress, na.PropertyAddress)
From PortfolioProject..NashvilleHousing n
JOIN PortfolioProject..NashvilleHousing na
	ON n.ParcelID = na.ParcelID
	AND n.[UniqueID ] <> na.[UniqueID ]
WHERE n.PropertyAddress is null

UPDATE n
SET PropertyAddress = ISNULL(n.PropertyAddress, na.PropertyAddress)
From PortfolioProject..NashvilleHousing n
JOIN PortfolioProject..NashvilleHousing na
	ON n.ParcelID = na.ParcelID
	AND n.[UniqueID ] <> na.[UniqueID ]
WHERE n.PropertyAddress is null


--Divide the ADDRESS, in address and city 

Select
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2),
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)


--Let's split the owner address as well

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N, in 'Sold as Vacant' field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


--Remove Duplicates, using a window function to find where they are

WITH RowNumCTE AS(
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
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate

Select *
FROM PortfolioProject..NashvilleHousing
