using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemPricingBl : IBusinessLayer<tblICItemPricing>
    {
        Task<SearchResult> GetItemPricingViews(GetParameter param);
        Task<SearchResult> GetItemStockPricingViews(GetParameter param);
    }

    public interface IItemPricingLevelBl : IBusinessLayer<tblICItemPricingLevel>
    {
        Task<SearchResult> GetItemPricingLevel(GetParameter param);
    }

    public interface IItemSpecialPricingBl : IBusinessLayer<tblICItemSpecialPricing>
    {
        Task<SearchResult> GetItemSpecialPricing(GetParameter param);
    }
}
