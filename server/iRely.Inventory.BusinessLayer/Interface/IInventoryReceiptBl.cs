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
        Task<SearchResult> SearchReceiptItems(GetParameter param);
        Task<SearchResult> SearchReceiptItemLots(GetParameter param);
        Task<SearchResult> GetAddOrders(GetParameter param, int VendorId, string ReceiptType, int SourceType);
        Task<SearchResult> GetReceiptVouchers(GetParameter param);
    }
}
