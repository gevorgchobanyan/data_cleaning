select * from housing

-- changing date format

ALTER TABLE housing 
ADD SaleDateFormated DATE;

UPDATE housing
SET SaleDateFormated = CONVERT(DATE, SaleDate, 103)

ALTER TABLE housing 
DROP COLUMN SaleDate;

-- swap PorpertyAddress NULL value  with address

SELECT * FROM housing WHERE PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- break down PropertyAddress & OwnerAddress into to columns

ALTER TABLE housing
ADD PropertyAddressStreet NVARCHAR(255);

ALTER TABLE housing
ADD PropertyAddressCity NVARCHAR(255);

UPDATE housing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE housing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

ALTER TABLE housing 
DROP COLUMN PropertyAddress;



-- owner address

ALTER TABLE housing
ADD OwnerAddressStreet NVARCHAR(255);

ALTER TABLE housing
ADD OwnerAddressCity NVARCHAR(255);

ALTER TABLE housing
ADD OwnerAddressState NVARCHAR(255);

UPDATE housing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE housing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE housing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


ALTER TABLE housing 
DROP COLUMN OwnerAddress;


-- removing duplicates

WITH CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From housing
)
Select *
From CTE
Where row_num > 1
Order by PropertyAddressStreet



SELECT 
    COUNT(*) LegalReference
FROM housing
GROUP BY
    [UniqueID ]
HAVING 
    COUNT(*) > 1;