using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryAdjustmentBl : IBusinessLayer<tblICInventoryAdjustment>
    {
        SaveResult PostTransaction(Common.Posting_RequestModel Adjustment, bool isRecap);
        SaveResult ValidateOutdatedStockOnHand(string transactionId);
        SaveResult UpdateOutdatedStockOnHand(string transactionId);
        SaveResult ValidateOutdatedExpiryDate(string transactionId);
        SaveResult UpdateOutdatedExpiryDate(string transactionId);
        Task<SearchResult> GetPostedLots(GetParameter param);
    }
}
