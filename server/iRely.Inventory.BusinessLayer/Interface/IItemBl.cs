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
        Task<SearchResult> GetAssemblyItems(GetParameter param);
        Task<SearchResult> GetItemUPCs(GetParameter param);
        Task<SearchResult> GetOtherCharges(GetParameter param);
        Task<SearchResult> GetStockTrackingItems(GetParameter param);       
        int? DuplicateItem(int intItemId);
    }
}
