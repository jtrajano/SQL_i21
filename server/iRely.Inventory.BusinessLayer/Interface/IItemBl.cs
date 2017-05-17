using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemBl : IBusinessLayer<tblICItem>
    {
        Task<SearchResult> GetCompactItems(GetParameter param);
        Task<SearchResult> GetAssemblyComponents(GetParameter param);
        Task<SearchResult> GetItemStocks(GetParameter param);
        Task<SearchResult> GetItemStockDetails(GetParameter param);
        Task<SearchResult> GetItemStockUOMSummary(int? ItemId, int? LocationId, int? SubLocationId, int? StorageLocationId);
        Task<SearchResult> GetAssemblyItems(GetParameter param);
        Task<SearchResult> GetBundleComponents(GetParameter param);
        Task<SearchResult> GetItemUPCs(GetParameter param);
        Task<SearchResult> GetInventoryValuation(GetParameter param);
        Task<SearchResult> GetInventoryValuationSummary(GetParameter param);
        Task<SearchResult> GetOtherCharges(GetParameter param);
        Task<SearchResult> GetItemCommodities(GetParameter param);
        Task<SearchResult> GetStockTrackingItems(GetParameter param);
        SaveResult CheckStockUnit(int ItemId, bool ItemStockUnit, int ItemUOMId);
        SaveResult ConvertItemToNewStockUnit(int ItemId, int ItemUOMId);
        SaveResult CopyItemLocation(int intSourceItemId, string strDestinationItemIds);
        ItemBl.DuplicateItemSaveResult DuplicateItem(int intItemId);
        Task<object> GetItemUOMsByType(int? intItemId, string strUnitType);
        Task<SearchResult> GetItemOwner(GetParameter param);
        Task<SearchResult> GetItemSubLocations(GetParameter param);
        Task<SearchResult> GetStockDetail(GetParameter param);
    }
}
