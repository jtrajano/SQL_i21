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
        Task<SearchResult> SearchItemStockUOMViewTotalsAllLocations(GetParameter param);
        Task<SearchResult> SearchItemStockUOMViewTotalsAllStorageUnits(GetParameter param);
        Task<SearchResult> SearchItemStockUOMViewTotals(GetParameter param);
        Task<SearchResult> GetLocationStockOnHand(int? intLocationId, int? intItemId, int? intSubLocationId, int? intStorageLocationId, int? intLotId, int? intItemUOMId);
        Task<SearchResult> SearchItemStockUOMForAdjustment(GetParameter param);
        Task<SearchResult> GetInventoryCountItemStockLookup(GetParameter param);
        Task<SearchResult> GetItemStorageLocations(GetParameter param);
        Task<SearchResult> GetItemSubLocations(GetParameter param);
    }
}
