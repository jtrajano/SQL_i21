﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryReceiptBl : IBusinessLayer<tblICInventoryReceipt>
    {
        SaveResult ProcessBill(int receiptId, out int? newBill);
        SaveResult CalculateCharges(int receiptId);
        SaveResult PostTransaction(Common.Posting_RequestModel receipt, bool isRecap);
        void SetUser(int UserId);
    }
}
