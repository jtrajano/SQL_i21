using iRely.Inventory.BusinessLayer;
using iRely.Inventory.Model;
using iRely.Inventory.Test.Import.Fake;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Moq;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Test.Import
{
    [TestClass]
    public class TestBrand
    {
        [TestMethod]
        public void TestBoolean()
        {
            var valid = false;
            valid = valid && true;

            Assert.IsTrue(valid);
        }

        //[TestMethod]
        //public async Task ImportBrands()
        //{
        //    var success = true;
        //    var message = "Successful.";

        //    var builder = new FakeBrandBuilder();
        //    var director = new FakeCsvDirector(builder);
        //    var data = Encoding.UTF8.GetBytes(director.BuildUnique().ToString());

        //    GlobalSettings.Instance.FileType = "text/csv;charset=UTF-8";
        //    GlobalSettings.Instance.AllowOverwriteOnImport = true;
        //    GlobalSettings.Instance.AllowDuplicates = false;
        //    GlobalSettings.Instance.ImportType = "Brands";
        //    GlobalSettings.Instance.FileName = "";
   
        //    //try
        //    //{
        //    //    var result = await i.Import();
        //    //    success = !result.Failed;
        //    //    message = result.Description;
        //    //}
        //    //catch (Exception ex)
        //    //{
        //    //    success = false;
        //    //    message = ex.InnerException.Message;
        //    //}

        //    Assert.IsTrue(success, message);
        //}
    }
}
