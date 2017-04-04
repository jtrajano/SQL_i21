using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface ICommodityAttributeBl : IBusinessLayer<tblICCommodityAttribute>
    {
        Task<SearchResult> SearchOriginAttributes(GetParameter param);
        Task<SearchResult> SearchProductTypeAttributes(GetParameter param);
        Task<SearchResult> SearchRegionAttributes(GetParameter param);
        Task<SearchResult> SearchSeasonAttributes(GetParameter param);
        Task<SearchResult> SearchClassAttributes(GetParameter param);
        Task<SearchResult> SearchProductLineAttributes(GetParameter param);
        Task<SearchResult> SearchGradeAttributes(GetParameter param);
    }
}
