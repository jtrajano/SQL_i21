﻿using System;
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
            InventoryReceipt = 23,
            LotNumber = 24,
            InventoryAdjustment = 30,
            InventoryShipment = 31,
            BuildAssembly = 35,
        }

        public class Posting_RequestModel
        {
            public string strTransactionId { get; set; }
            public bool isPost { get; set; }
            public bool isRecap { get; set; }
            public int intUserId { get; set; }
            public int intEntityId { get; set; }
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
