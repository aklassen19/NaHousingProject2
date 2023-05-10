SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

SELECT SaleDate, Convert(Date,SaleDate) as SaleDate2
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, SaleDate)

--** Green script below is to make SaleDate and SaleDate2 identical but did not work for me
--Alter Table NashvilleHousing
--Add SaleDateConverted Date;

--Update NashvilleHousing
--Set SaleDateConverted = Convert(Date,SaleDate)


--Populate Propert Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


--AlexTheAnalyst Project 3 vid @ 13.30 covers this Join

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--This update fixed the code above so that if a.propertyaddress is null it will be given b.propertyaddress
Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


--This pulls everything in the address line before the comma. the -1 puts it right before.
--This will create 2 new columns
SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing


--This will alter the table and Add propertysplitcity and propertysplitaddress to the table

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Owneraddress being split by ParseName and adding the columns to the table


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.') ,3) 
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1) 
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.') ,3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NvarChar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NvarChar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.') ,1)

SELECT *
From PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No in  'SoldAsVacant' field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
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
--order by ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


SELECT *
From PortfolioProject.dbo.NashvilleHousing

--Delete Unused Columns

SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate