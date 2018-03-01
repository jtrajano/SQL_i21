using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemLocationBl : IBusinessLayer<tblICItemLocation>
    {
        Task<SearchResult> SearchItemLocationViews(GetParameter param);
        Task<GetObjectResult> GetItemLocation(GetParameter param);
        SaveResult CheckCostingMethod(int ItemId, int ItemLocationId, int CostingMethod);
        Task<GetObjectResult> GetItemsWithNoLocation(GetParameter param);
    }
}
