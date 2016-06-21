using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IInventoryCountBl : IBusinessLayer<tblICInventoryCount>
    {
        Task<SearchResult> GetCountSheets(GetParameter param, int CountId);
        SaveResult LockInventory(int InventoryCountId, bool ysnLock = true);
        SaveResult PostInventoryCount(Common.Posting_RequestModel count, bool isRecap);
        Task<SearchResult> GetItemStockSummary(GetParameter param);
        Task<SearchResult> GetItemStockSummaryByLot(GetParameter param);
    }
}
