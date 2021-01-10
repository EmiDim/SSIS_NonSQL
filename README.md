# Performing ETL process using Non-SQL programming and SSIS
<p>Project for ETL process using a variety of Non-SQL options like C# Application, C# script, Python and PowerShell script. </p>
<p>Solution contains one SSIS project that contains 4 different ETL processes: C# script, C# console application, PowerShell script and Python script. SSIS project has one package. Whole solution contains that SSIS project, C# console application, C# class, plus code for PowerShell, C#, and Python that are put into subfolders.</p>
<p>This ETL process is starting with generating list of all valid world currencies, then checking the exchange rate data for validity and applying prices in currencies in Products data. For simplicity, I added just prices in USD and EUR.</p>

## Data Source
<ul>
  <li>CurrencyList.txt - List of all countries and their currencies.</li>
  <li>ExchangeRates.csv - Current exchange rates.</li>
  <li>SQL query that extracts Products with their Subcategories and categories from AdventureWorks_Basics database.</li>
</ul>

## Transformation
<ul>
<li>CurrencyList.txt is cleared of all rows that does not contains valid currencies and results are saved in two separate files: validCurrencyList.txt and invalidCurrencyList.txt. One currency is valid when it has three upper letter code and is checked with regex matching.</li>
<li>ExchangeRates.csv is checked for valid and invalid currency rows, or it has three upper letter code and is contained in valid currency list produced with previous step. Results are saved in two separate files: validExchangeRates.csv and invalidExchangeRates.csv</li>
<li>Results from the SQL query is cleared from null values and two new columns are added ProductPrice in USD and ProductPrice in EUR calculated with exchange rates from previous step. Result is saved in ProductsForImport.csv file</li>
</ul>

## Load
Each result file is loaded in its own staging table in DWAdventureWorks_Basics database
<table style="width:100%">
  <tr>
    <th>Source</th>
    <th>Result File</th>
    <th>Staging Table</th>
  </tr>
  <tr>
    <td rowspan="2"CurrencyList.txt</td>
    <td>validCurrencyList.txt</td>
    <td>StagingValidCurrencies</td>
  </tr>
  <tr>
    <td>invalidCurrencyList.txt</td>
    <td>StagingInValidCurrencies</td>
  </tr>
  <tr>
    <td rowspan="2">ExchangeRates.csv</td>
    <td>validExchangeRates.csv</td>
    <td>StagingExchangeRates</td>
  </tr>
  <tr>
    <td>invalidExchangeRates.csv</td>
    <td></td>
  </tr>
  <tr>
    <td>SQL query</td>
    <td>ProductsForImport.csv</td>
    <td>StagingProducts</td>
  </tr>
</table>
