import re
import csv
import pyodbc
from decimal import *

# Currency
strSourceDataFileName = "C:\\CurrencyData\\CurrencyList.txt"
strValidDataFileName = "C:\\CurrencyData\\validCurrencyList.txt"
strInvalidDataFileName = "C:\\CurrencyData\\invalidCurrencyList.txt"

# Open Currency Files for Writing
objValidDataStream = open(strValidDataFileName, 'w')
objInvalidDataStream = open(strInvalidDataFileName, 'w')

# Read a line of text from the Currencies source file
objSourceDataStream = open(strSourceDataFileName, 'r')

# Check Currencies
strRegex = "[A-Z]{3}"
i=0
ccyList=[]
for strLine in objSourceDataStream:
    lineArray =strLine.split('\t')
    if(i>0):
        if(re.search(strRegex,lineArray[2])):
            objValidDataStream.write(lineArray[0] + '\t' + lineArray[1] + '\t' + lineArray[2] + '\t' + lineArray[3] +'\n')
            ccyList.append(lineArray[2])
        else:
            objInvalidDataStream.write(strLine)
    i=i+1

objSourceDataStream.close()
objValidDataStream.close()
objInvalidDataStream.close()

USDrate=0
EURrate=0

# Exchange Rate
csvSourceDataFileName = "C:\\CurrencyData\\ExchangeRates.csv"
csvValidDataFileName = "C:\\CurrencyData\\validExchangeRates.csv"
csvInvalidDataFileName = "C:\\CurrencyData\\invalidExchangeRates.csv"

# Open Exchange Rate Files for Writing
objValidERDataStream = open(csvValidDataFileName, 'w')
objInvalidERDataStream = open(csvInvalidDataFileName, 'w')

# Check validity of currencies
with open(csvSourceDataFileName) as ERcsv:
    csv_reader = csv.reader(ERcsv, delimiter=',')
    i=0
    for lineArray in csv_reader:
        if(i>0):
            lineArray[0]=lineArray[0].replace("Â\xa0", " ")
            if(re.search(strRegex,lineArray[0].strip()) and (lineArray[0].strip() in ccyList)):
                objValidERDataStream.write(lineArray[0] + ',' + lineArray[1] + ',' + lineArray[2] +'\n')
                if (lineArray[0].strip()=="EUR"):
                    EURrate=Decimal(lineArray[2])
                if (lineArray[0].strip()=="USD"):
                    USDrate=Decimal(lineArray[2])
            else:
                objInvalidERDataStream.write(lineArray[0] + ',' + lineArray[1] + ',' + lineArray[2] +'\n')
        i=i+1
        
objValidERDataStream.close()
objInvalidERDataStream.close()

#Products
ProductsDataFileName = "C:\\CurrencyData\\ProductsForImport.csv"

objProductsDataStream = open(ProductsDataFileName, 'w', newline='\n', encoding='utf-8')
mywriter = csv.DictWriter(objProductsDataStream, fieldnames=['ProductID','ProductName','ProductPrice','ProductSuccategoryID','ProductSubcategoryName','ProductCategoryID','ProductCategoryName','ProductPriceUSD','ProductPriceEUR'])
mywriter.writeheader()

priceUSD=Decimal(0.00)
priceEUR=Decimal(0.00)
# Get Products from DataBase
conn = pyodbc.connect('driver={SQL Server};server=DESKTOP-BME09T7\MSSQLSERVER01;database=AdventureWorks_Basics;Trusted_Connection=yes')

cur = conn.cursor()
sql_command="select P.ProductID,P.Name as ProductName,P.ListPrice as ProductPrice, PS.ProductSubcategoryID as ProductSubcategoryID, PS.Name as ProductSubcategoryName,PC.ProductCategoryID as ProductCategoryID,PC.Name as ProductCategoryName from AdventureWorks_Basics.dbo.Products as P left outer join AdventureWorks_Basics.dbo.ProductSubcategory as PS on P.ProductSubcategoryID=Ps.ProductCategoryID left outer join AdventureWorks_Basics.dbo.ProductCategory as PC on PS.ProductCategoryID=PC.ProductCategoryID"
res = cur.execute(sql_command)
for row in res:
    if(row[3] is None and row[5] is None):
        row[3]=-1
        row[5]=-1
    if(row[4] is None and row[6] is None):
        row[4]='NA'
        row[6]='NA'
    if (EURrate==1):
        priceUSD=row[2]
        priceEUR=round(row[2]/USDrate,4)
    mywriter.writerow({'ProductID':row[0],
                       'ProductName':row[1],
                       'ProductPrice':row[2],
                       'ProductSuccategoryID':row[3],
                       'ProductSubcategoryName':row[4],
                       'ProductCategoryID':row[5],
                       'ProductCategoryName':row[6],
                       'ProductPriceUSD':priceUSD,
                       'ProductPriceEUR':priceEUR
                       })

objProductsDataStream.close()

