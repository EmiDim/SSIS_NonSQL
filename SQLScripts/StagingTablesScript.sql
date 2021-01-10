use DWAdventureWorks_Basics
go

If (object_id('StagingValidCurrencies') is not null)
Drop Table StagingValidCurrencies;
Go
Create Table StagingValidCurrencies
(CurrencyCode nvarchar(3),
CurrencyNumericCode int,
CurrencyName nvarchar(100),
Entity nvarchar(300));
Go

If (object_id('StagingInValidCurrencies') is not null)
Drop Table StagingInValidCurrencies;
Go
Create Table StagingInValidCurrencies
( Entity nvarchar(300));

If (object_id('StagingExchangeRates') is not null)
Drop Table StagingExchangeRates;
Go
Create Table StagingExchangeRates
(CurrencyCode nvarchar(3),
ExchangeRate decimal(18,4));

If (object_id('StagingProducts') is not null)
Drop Table StagingProducts;
Go
CREATE TABLE StagingProducts(
	[ProductID] [int] NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductPrice] [decimal](18, 4) NOT NULL,
	[ProductSubCategoryID] [int] NOT NULL,
	[ProductSubCategoryName] [nvarchar](50) NOT NULL,
	[ProductCategoryID] [int] NOT NULL,
	[ProductCategoryName] [nvarchar](50) NOT NULL,
	[ProductPriceUSD] [decimal](18, 4) NOT NULL,
	[ProductPriceEUR] [decimal](18, 4) NOT NULL);