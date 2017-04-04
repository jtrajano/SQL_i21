using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemStockBl : IBusinessLayer<tblICItemStock>
    {
        Task<SearchResult> SearchItemStockUOMs(GetParameter param);
        Task<SearchResult> SearchItemStockUOMViewTotals(GetParameter param);
        Task<SearchResult> GetLocationStockOnHand(int intLocationId, int intItemId);
        Task<SearchResult> SearchItemStockUOMForAdjustment(GetParameter param);
    }
}
