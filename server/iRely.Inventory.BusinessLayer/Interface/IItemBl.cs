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
        Task<SearchResult> SearchCompactItems(GetParameter param);
        Task<SearchResult> SearchAssemblyComponents(GetParameter param);
        Task<SearchResult> SearchItemStocks(GetParameter param);
        Task<SearchResult> SearchItemStockDetails(GetParameter param);
        Task<SearchResult> GetItemStockUOMSummary(int? ItemId, int? LocationId, int? SubLocationId, int? StorageLocationId);
        Task<SearchResult> SearchAssemblyItems(GetParameter param);
        Task<SearchResult> SearchBundleComponents(GetParameter param);
        Task<SearchResult> SearchItemUPCs(GetParameter param);
        Task<SearchResult> SearchInventoryValuation(GetParameter param);
        Task<SearchResult> SearchInventoryValuationSummary(GetParameter param);
        Task<SearchResult> SearchOtherCharges(GetParameter param);
        Task<SearchResult> SearchItemCommodities(GetParameter param);
        Task<SearchResult> SearchStockTrackingItems(GetParameter param);
        SaveResult CheckStockUnit(int ItemId, bool ItemStockUnit, int ItemUOMId);
        SaveResult ConvertItemToNewStockUnit(int ItemId, int ItemUOMId);
        SaveResult CopyItemLocation(int intSourceItemId, string strDestinationItemIds);
        ItemBl.DuplicateItemSaveResult DuplicateItem(int intItemId);
        Task<object> GetItemUOMsByType(int? intItemId, string strUnitType);
        Task<SearchResult> SearchItemOwner(GetParameter param);
        Task<SearchResult> SearchItemSubLocations(GetParameter param);

    }
}
