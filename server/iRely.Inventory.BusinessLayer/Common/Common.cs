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
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class Common
    {
        public enum StartingNumber
        {
            InventoryReceipt = 23,
            LotNumber = 24,
            InventoryAdjustment = 30,
            InventoryShipment = 31,
            BuildAssembly = 35,
            InventoryTransfer = 41,
            StorageMeasurementReading = 69,
            InventoryCount = 76
        }

        public class Posting_RequestModel
        {
            public string strTransactionId { get; set; }
            public bool isPost { get; set; }
            public bool isRecap { get; set; }
            public int intUserId { get; set; }
            public int intEntityId { get; set; }
        }

        public class GLPostResult
        {
            public Exception BaseException { get; set; }
            public ServerException Exception { get; set; }
            public bool HasError { get; set; }
            public int RowsAffected { get; set; }
            public string strBatchId { get; set; }
        }

        //public static string GetStartingNumber(StartingNumber transaction)
        //{
        //    var _db = new Repository(new Inventory.Model.InventoryEntities());
        //    tblSMStartingNumber startingNumber = _db.GetQuery<tblSMStartingNumber>().Find((int)transaction);
        //    string strTransactionId = string.Empty;
        //    if (startingNumber != null)
        //    {
        //        strTransactionId = string.Concat(startingNumber.strPrefix.ToString(), startingNumber.intNumber.ToString());
        //        startingNumber.intNumber += 1;
        //        _db.Save();
        //        _db.Dispose();
        //    }
        //    return strTransactionId;
        //}

        //public static async Task<string> GetStartingNumberAsync(StartingNumber transaction)
        //{
        //    var _db = new Repository(new Inventory.Model.InventoryEntities());
        //    tblSMStartingNumber startingNumber = await _db.GetQuery<tblSMStartingNumber>().FindAsync((int)transaction);
        //    string strTransactionId = string.Empty;
        //    if (startingNumber != null)
        //    {
        //        strTransactionId = string.Concat(startingNumber.strPrefix.ToString(), startingNumber.intNumber.ToString());
        //        startingNumber.intNumber += 1;
        //        await _db.SaveAsync(false);

        //        _db.Dispose();
        //    }
        //    return strTransactionId;
        //}

        //public static string GetStartingNumber(StartingNumber transaction, int? locationId)
        //{
        //    var _db = new Repository(new Inventory.Model.InventoryEntities());
        //    var db = (Inventory.Model.InventoryEntities)_db.ContextManager;

        //    return (db.GetStartingNumber((int)transaction, locationId));
        //}
    }
}
