using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Web;

using iRely.Common;
using iRely.Inventory.Model;
using IdeaBlade.Core;
using IdeaBlade.Linq;

namespace iRely.Inventory.BRL
{
    public class Common
    {
        public enum StartingNumber
        {
            InventoryReceipt = 23
        }

        public static string GetStartingNumber(StartingNumber transaction) 
        {
            var _db = new Repository(new Inventory.Model.InventoryEntities());
            tblSMStartingNumber startingNumber = _db.GetQuery<tblSMStartingNumber>().Find((int)transaction);

            string strTransactionId = string.Concat(startingNumber.strPrefix, startingNumber.intNumber);
            startingNumber.intNumber += 1;
            _db.Save();

            return strTransactionId;
        }

    }
}
