$strSourceDataFileName = "C:\CurrencyData\CurrencyList.txt"
$strValidDataFileName = "C:\CurrencyData\validCurrencyList.txt"
$strInvalidDataFileName = "C:\CurrencyData\invalidCurrencyList.txt"

$csvSourceFileName="C:\CurrencyData\ExchangeRates.csv"
$csvValidFileName="C:\CurrencyData\validExchangeRates.csv"
$csvInvalidFileName="C:\CurrencyData\invalidExchangeRates.csv"

#Open Files for Writing
$objValidDataStream = [System.IO.StreamWriter]$strValidDataFileName
$objInvalidDataStream = [System.IO.StreamWriter]$strInvalidDataFileName

$i=0
$Tab = [char]9
$strRegex = "\b[A-Z]{3}\b"

$ccyList=New-Object Collections.Generic.List[string]

#Read a line of text from the source file
foreach($strLine in Get-Content $strSourceDataFileName) { 
    $LineArray =$strLine.Split($Tab)
    If ($i -gt 0)
    {
    If (($LineArray.Length -ge 3) -and ($LineArray[2] -match $strRegex))
    {
        $objValidDataStream.WriteLine($LineArray[0] + $Tab + $LineArray[1] + $Tab + $LineArray[2] + $Tab + $LineArray[3]) 
        $ccyList.Add($LineArray[2])
    }
    else
    {
        $objInvalidDataStream.WriteLine($strLine)
    }
    }
   $i++
}


$objValidDataStream.Close()
$objInvalidDataStream.Close()

$USDrate=0.00
$EURrate=0.00

$objValidERDataStream = [System.IO.StreamWriter]$csvValidFileName
$objInvalidERDataStream = [System.IO.StreamWriter]$csvInvalidFileName

$i=0
foreach($strLine in Get-Content $csvSourceFileName) { 
    $LineArray =$strLine.Split(',')
    If ($i -gt 0)
    {
    If (($LineArray[0].Trim() -match $strRegex) -and ($ccyList -contains $LineArray[0].Trim()))
    {
        $objValidERDataStream.WriteLine($strLine.Trim())	
	If($LineArray[0].Trim() -eq "EUR"){
		$EURrate=$LineArray[2]
	}
	If($LineArray[0].Trim() -eq "USD"){
		$USDrate=$LineArray[2]
	}
    }
    else
    {
        $objInvalidERDataStream.WriteLine($strLine.Trim())
    }
    }
   $i++
}

$objValidERDataStream.Close()
$objInvalidERDataStream.Close()

Add-Content -Path C:\CurrencyData\ProductsForImport.csv  -Value '"ProductID","ProductName","ProductPrice","ProductSubcategoryID","ProductSubcategoryName","ProductCategoryID","ProductCategoryName","ProductPriceUSD","ProductPriceEUR"'

$SQLServer = "DESKTOP-BME09T7\MSSQLSERVER01"
$db = "AdventureWorks_Basics"
$selectdata = "select P.ProductID,P.Name as ProductName,P.ListPrice as ProductPrice, PS.ProductSubcategoryID as ProductSubcategoryID, PS.Name as ProductSubcategoryName, PC.ProductCategoryID as ProductCategoryID,PC.Name as ProductCategoryName
 from AdventureWorks_Basics.dbo.Products as P left outer join AdventureWorks_Basics.dbo.ProductSubcategory as PS on P.ProductSubcategoryID=Ps.ProductCategoryID left outer join AdventureWorks_Basics.dbo.ProductCategory as PC on PS.ProductCategoryID=PC.ProductCategoryID"

## Run Query and Get Products
$SQLResults =Invoke-Sqlcmd -ServerInstance $SQLServer -Database $db -Query $selectdata 

$priceUSD=[System.Decimal]0.00
$priceEUR=[System.Decimal]0.00
$subCategoryID
$categoryID
$subCategoryName
$categoryName
$products = @()
foreach($Row in $SQLResults)
{
	if(($Row.ItemArray[3] -eq [DBNull]::Value) -and ($Row.ItemArray[5] -eq [DBNull]::Value)){
	        	$subCategoryID=-1
        		$categoryID=-1
	}
	else{
		$subCategoryID=$Row.ItemArray[3]
        		$categoryID=$Row.ItemArray[5]
	}
	if(($Row.ItemArray[4] -eq [DBNull]::Value) -and ($Row.ItemArray[6] -eq [DBNull]::Value)){
	        	$subCategoryName='NA'
        		$categoryName='NA'
	}
	else{
		$subCategoryName=$Row.ItemArray[4]
        		$categoryName=$Row.ItemArray[6]
	}	
	 if([System.Decimal]$EURrate -eq [System.Decimal]1){
        		$priceUSD=[System.Decimal]$Row.ItemArray[2]
        		$priceEUR= [math]::Round([System.Decimal]$Row.ItemArray[2]/$USDrate,4)
	}
	$newRow=[PSCustomObject]@{
		ProductID=$Row.ItemArray[0]
		ProductName=$Row.ItemArray[1]
		ProductPrice=$Row.ItemArray[2]
		ProductSubcategoryID=$subCategoryID
		ProductSubcategoryName=$subCategoryName
		ProductCategoryID=$categoryID
		ProductCategoryName=$categoryName
		ProductPriceUSD=$priceUSD
		ProductPriceEUR=$priceEUR
	}
	$products +=$newRow
}
##write-host $Row.ItemArray;
	$products | Export-Csv -NoTypeInformation -Path C:\CurrencyData\ProductsForImport.csv