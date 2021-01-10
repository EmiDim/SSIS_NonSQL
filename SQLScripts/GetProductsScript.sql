use AdventureWorks_Basics
go

select P.ProductID,
P.Name as ProductName,
P.ListPrice as ProductPrice, 
PS.ProductSubcategoryID as ProductSubcategoryID, 
PS.Name as ProductSubcategoryName, 
PC.ProductCategoryID as ProductCategoryID,
PC.Name as ProductCategoryName
from Products as P
left outer join ProductSubcategory as PS
on P.ProductSubcategoryID=Ps.ProductCategoryID
left outer join ProductCategory as PC
on PS.ProductCategoryID=PC.ProductCategoryID

