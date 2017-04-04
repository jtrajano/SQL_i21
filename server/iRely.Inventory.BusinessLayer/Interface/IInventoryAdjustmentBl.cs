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
        Task<SearchResult> SearchPostedLots(GetParameter param);
        Task<SearchResult> SearchAdjustmentDetails(GetParameter param);
    }
}
