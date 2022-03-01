select * from dbo.nashvillehousing

-- standardize date format

select cast( SaleDATE as date )FROM dbo.nashvillehousing

alter table nashvillehousing
add salesdateconverted date

update nashvillehousing
set salesdateconverted =convert(date,saledate)

select saledate, salesdateconverted from nashvillehousing


-- populate property address data
 
-- tells the total number of propertyaddress that is null
select count(*) from nashvillehousing
where propertyaddress is null

select  a.parcelid, a.propertyaddress ,b.parcelid,b.propertyaddress
from dbo.nashvillehousing a
join
dbo.nashvillehousing b

on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select  a.parcelid, a.propertyaddress ,b.parcelid,b.propertyaddress,isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.nashvillehousing a
join
dbo.nashvillehousing b

on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--used a isnull statemnets to replace the isnull with the prperyt address of b for the quuery
select  a.parcelid, isnull(a.propertyaddress,b.propertyaddress) as propertyaddress,b.parcelid,b.propertyaddress
from dbo.nashvillehousing a
join
dbo.nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
-- used a case statemnets to replace the isnull with the prperyt address of b for the quuery
select  a.parcelid, case when a.PropertyAddress is null then b.PropertyAddress end  as propertyaddress ,b.parcelid,b.propertyaddress
from dbo.nashvillehousing a
join
dbo.nashvillehousing b

on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- to update the is null to property address of the duplcates

update  a 
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join
nashvillehousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- this shows the variation of parcelid with duplactes and withou duplicates
select count (distinct(parcelid)) as parcelidwithouduplicates, count(parcelid)   as withduplicates from nashvillehousing


--breaking address into individual columns (address,city,state)

select * from nashvillehousing

select charindex(',',PROPERTYADDRESS) FROM nashvillehousing

select substring (propertyaddress,1,charindex(',',propertyaddress)-1) as address ,substring(propertyaddress, charindex(',',propertyaddress)+1,(len(propertyaddress)- charindex(',',propertyaddress)+1)) as addresss from nashvillehousing

alter table nashvillehousing
add propertysplitaddress nvarchar(255)

alter table nashvillehousing
add propertysplicity nvarchar(255)

 update nashvillehousing
 set propertysplitaddress = substring (propertyaddress,1,charindex(',',propertyaddress)-1)

 update nashvillehousing
 set propertysplicity = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

 
select  count(distinct(owneraddress)) from nashvillehousing

select PARSENAME( REPLACE(owneraddress,',','.'), 3) as owneraddress,PARSENAME( REPLACE(owneraddress,',','.'), 2) as onwercity,PARSENAME( REPLACE(owneraddress,',','.'), 1) as ownerstate from nashvillehousing


alter table nashvillehousing
add ownersplitaddress nvarchar(255)

alter table nashvillehousing
add ownersplicity nvarchar(255)

alter table nashvillehousing
add ownersplitstate nvarchar(255)


update nashvillehousing

set ownersplicity =PARSENAME( REPLACE(owneraddress,',','.'), 2)

update nashvillehousing

set ownersplitaddress =PARSENAME( REPLACE(owneraddress,',','.'), 3)

update nashvillehousing

set ownersplitstate =PARSENAME( REPLACE(owneraddress,',','.'), 1)


select * from nashvillehousing


 --change y to yes and n to no  soldasvacant



 select SoldAsVacant ,count(SoldAsVacant) from nashvillehousing
 group by SoldAsVacant
 order by SoldAsVacant

 select * from nashvillehousing

 update nashvillehousing
 set SoldAsVacant= case when SoldAsVacant= 'y' then 'yes' when  SoldAsVacant ='n' then 'no' else soldasvacant end 
 --- remove duplicates
 -- we included the use of cte
 with rownumcte as(
 
 select  *, row_number() over( partition by parcelid,propertyaddress,saleprice,saledate,legalreference  order by uniqueid) row_num   from nashvillehousing
-- order by ParcelID
  )


  select * from rownumcte
  where  row_num >1
  order by PropertyAddress

  -- to now delete it
   with rownumcte as(
 
 select  *, row_number() over( partition by parcelid,propertyaddress,saleprice,saledate,legalreference  order by uniqueid) row_num   from nashvillehousing
-- order by ParcelID
  )


 delete  from rownumcte
  where  row_num >1
  




 












