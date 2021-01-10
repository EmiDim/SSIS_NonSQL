using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CurrencyValidatorConsoleApp
{
    class Program
    {

        static void Main(string[] args)
        {
            List<string> ccyList;
            CurrencyValidator.CurrencyValidatorClass.ValidateCcyFile(out ccyList);
            List<string> validRate = CurrencyValidator.CurrencyValidatorClass.ValidateExchRateFile(ccyList);

            Console.WriteLine("Valid Currencies: " + ccyList.Count.ToString());

            CurrencyValidator.CurrencyValidatorClass.GetProducts(validRate);
        }
    }
}
