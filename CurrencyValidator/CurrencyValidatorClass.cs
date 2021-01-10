using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;

namespace CurrencyValidator
{
    public class CurrencyValidatorClass
    {
        //public static bool isValidCcy(string[] lineValues)
        //{
        //    if (lineValues.Length >= 3 && !String.IsNullOrEmpty(lineValues[2].ToString()) && lineValues[2].ToString().Length == 3)
        //    {
        //        return true;
        //    }
        //    else
        //    {
        //        return false;
        //    }
        //}

        public static bool isValidCcy(string Ccy)
        {
            string strPattern = @"\b[A-Z]{3}\b";
            bool isValid = false;

            System.Text.RegularExpressions.Regex regex = new System.Text.RegularExpressions.Regex(strPattern);
            System.Text.RegularExpressions.Match match = regex.Match(Ccy);
            if (match.Success) isValid = true;

            return isValid;
        }

        public static void ValidateCcyFile(out List<string> ccyList)
        {
            StreamReader reader = new StreamReader(File.OpenRead(@"C:\CurrencyData\CurrencyList.txt"), Encoding.UTF8);
            int i = 0;

            List<string> validCcy = new List<string>();
            List<string> invalidCcy = new List<string>();
            ccyList = new List<string>();

            while (!reader.EndOfStream)
            {
                string readLine = reader.ReadLine();
                if (!String.IsNullOrWhiteSpace(readLine) && i > 0)
                {
                    string[] lineValues = readLine.Split('\t');
                    if (!isValidCcy(lineValues[2]))
                    {
                        invalidCcy.Add(readLine);
                    }
                    else
                    {
                        validCcy.Add(lineValues[0] + '\t' + lineValues[1] + '\t' + lineValues[2] + '\t' + lineValues[3]);
                        ccyList.Add(lineValues[2].ToString());
                        //validCcy.Add(readLine);
                    }
                }
                i += 1;
            }

            System.IO.File.WriteAllLines(@"C:\CurrencyData\invalidCurrencyList.txt", invalidCcy, Encoding.UTF8);
            System.IO.File.WriteAllLines(@"C:\CurrencyData\validCurrencyList.txt", validCcy, Encoding.UTF8);
        }

        public static List<string> ValidateExchRateFile(List<string> ccyList)
        {
            StreamReader reader = new StreamReader(File.OpenRead(@"C:\CurrencyData\ExchangeRates.csv"), Encoding.UTF8);
            int i = 0;

            List<string> validRate = new List<string>();
            List<string> invalidRate = new List<string>();

            while (!reader.EndOfStream)
            {
                string readLine = reader.ReadLine();
                if (!String.IsNullOrWhiteSpace(readLine) && i > 0)
                {
                    string[] lineValues = readLine.Split(',');
                    if (!isValidCcy(lineValues[0].ToString().Trim()) || !ccyList.Contains(lineValues[0].ToString().Trim()))
                    {
                        invalidRate.Add(readLine);
                    }
                    else
                    {
                        validRate.Add(readLine.Trim());
                    }
                }
                i += 1;
            }

            System.IO.File.WriteAllLines(@"C:\CurrencyData\invalidExchangeRates.csv", invalidRate, Encoding.UTF8);
            System.IO.File.WriteAllLines(@"C:\CurrencyData\validExchangeRates.csv", validRate, Encoding.UTF8);

            return validRate;
        }

        public static void GetProducts(List<string> exchangeRates)
        {
            decimal EURrate= decimal.Parse(exchangeRates.Find(x => x.Split(',')[0] == "EUR").Split(',')[2]);
            decimal USDrate = decimal.Parse(exchangeRates.Find(x => x.Split(',')[0] == "USD").Split(',')[2]);

            if (EURrate==1)
            {
                EURrate = 1 / USDrate;
                USDrate = 1;
            }
            string connectionString = @"Server=DESKTOP-BME09T7\MSSQLSERVER01;database=AdventureWorks_Basics;Trusted_Connection=yes";
            string queryString = "select P.ProductID,P.Name as ProductName,P.ListPrice as ProductPrice, PS.ProductSubcategoryID as ProductSubcategoryID, PS.Name as ProductSubcategoryName,PC.ProductCategoryID as ProductCategoryID,PC.Name as ProductCategoryName from AdventureWorks_Basics.dbo.Products as P left outer join AdventureWorks_Basics.dbo.ProductSubcategory as PS on P.ProductSubcategoryID=Ps.ProductCategoryID left outer join AdventureWorks_Basics.dbo.ProductCategory as PC on PS.ProductCategoryID=PC.ProductCategoryID";

            int pSuccategoryID = 0;
            int pCategoryID = 0;
            string pSuccategoryName = null;
            string pCategoryName = null;
            List<string> products = new List<string>();
            products.Add(String.Join(",",
                            "ProductID",
                            "ProductName",
                            "ProductPrice",
                            "ProductSubcategoryID",
                            "ProductSubcategoryName",
                            "ProductCategoryID",
                            "ProductCategoryName",
                            "ProductPriceUSD",
                            "ProductPriceEUR"
                            ));
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                SqlCommand command = new SqlCommand(queryString, connection);
                connection.Open();
                SqlDataReader reader = command.ExecuteReader();
                try
                {
                    while (reader.Read())
                    {
                        if(String.IsNullOrEmpty(reader["ProductSubcategoryID"].ToString()) && String.IsNullOrEmpty(reader["ProductCategoryID"].ToString()))
                        {
                            pSuccategoryID = -1;
                            pCategoryID = -1;
                        }
                        else
                        {
                            pSuccategoryID = (int)reader["ProductSubcategoryID"];
                            pCategoryID = (int)reader["ProductCategoryID"];
                        }
                        if (String.IsNullOrEmpty(reader["ProductSubcategoryName"].ToString()) && String.IsNullOrEmpty(reader["ProductCategoryName"].ToString()))
                        {
                            pSuccategoryName = "NA";
                            pCategoryName = "NA";
                        }
                        else
                        {
                            pSuccategoryName = reader["ProductSubcategoryName"].ToString();
                            pCategoryName = reader["ProductCategoryName"].ToString();
                        }
                        products.Add(String.Join(",",
                            reader["ProductID"],
                            "\"" + reader["ProductName"]+ "\"",
                            reader["ProductPrice"],
                            pSuccategoryID,
                            pSuccategoryName,
                            pCategoryID,
                            pCategoryName,
                            (decimal)reader["ProductPrice"]*USDrate,
                            (decimal)reader["ProductPrice"] * EURrate
                            ));
                    }
                }
                finally
                {
                    reader.Close();
                }
                connection.Close();
            }
            System.IO.File.WriteAllLines(@"C:\CurrencyData\ProductsForImport.csv", products, Encoding.UTF8);
        }
    }
}
