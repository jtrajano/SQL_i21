using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using iRely.Inventory.BusinessLayer;
using iRely.Inventory.Model;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace iRely.Inventory.Test.Import
{
    /*
     *  https://romiller.com/2012/02/14/testing-with-a-fake-dbcontext/
     *   > Duplicates in CSV
         > Exists in Db
         > Null or empty values for required lookup fields
         > Null or empty values for non-required lookup fields
         > Invalid values for lookups
         > Empty values for non-lookups
         > Empty CSV record
    */
    [TestClass]
    public class TestCsvReader
    {
        //[TestMethod]
        public async Task TestImportFromCsvFile()
        {
            CsvDataReader<tblICRinFuel> csv = new CsvDataReader<tblICRinFuel>(new string[] { "Code", "Description" });
            bool success = false;
            var message = "Import successful.";
            var options = new CsvOptions()
            {
                CheckDuplicates = true,
                ContinueOnFailure = false
            };
            try
            {
                success = await csv.ReadCsvAsync(@"C:\artifacts\Fuel Codes.csv", options);
                if (!success) message = "Import failed.";
            }
            catch (CsvMissingFieldsException ex)
            {
                success = false;
                message = ex.Message;
                Debug.WriteLine(message);
            }
            catch (Exception ex)
            {
                success = false;
                message = "An unexpected error has occurred. " + ex.Message;
                Debug.WriteLine(message);
            }
            Assert.IsTrue(success, message);
        }

        [TestMethod]
        public async Task TestImportFromCsv()
        {
            var options = new CsvOptions()
            {
                CheckDuplicates = true,
                ContinueOnFailure = false
            };

            CsvDataReader<tblICRinFuel> csv = new CsvDataReader<tblICRinFuel>(new string[] { "Code", "Description" });
            bool success = false;
            var message = "Import successful.";
            try
            {
                success = await csv.ReadCsvAsync(FakeCsvGenerator.CreateCsvReader(), options);
                if (!success) message = "Import failed.";
            }
            catch (CsvMissingFieldsException ex)
            {
                success = false;
                message = ex.Message;
            }
            catch (Exception ex)
            {
                success = false;
                message = "An unexpected error has occurred. " + ex.Message;
            }

            Assert.IsTrue(success, message);
        }

        [TestMethod]
        public async Task TestMissingFields()
        {
            CsvDataReader<tblICRinFuel> csv = new CsvDataReader<tblICRinFuel>(new string[] { "Code", "Description", "Active" }); // Active is missing in the CSV file.
            bool failed = true;
            var message = "Import successful.";
            try
            {
                failed = !await csv.ReadCsvAsync(FakeCsvGenerator.CreateCsvReader());
            }
            catch(CsvMissingFieldsException ex)
            {
                failed = true;
                message = ex.Message;
            }
            catch(Exception ex)
            {
                failed = true;
                message = "An unexpected error has occurred. " + ex.Message;
            }
            
            Assert.IsTrue(failed, message);
        }
    }
}
