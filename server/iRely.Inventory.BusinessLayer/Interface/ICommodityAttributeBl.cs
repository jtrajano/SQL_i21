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
        Task<SearchResult> GetOriginAttributes(GetParameter param);
        Task<SearchResult> GetProductTypeAttributes(GetParameter param);
        Task<SearchResult> GetRegionAttributes(GetParameter param);
        Task<SearchResult> GetSeasonAttributes(GetParameter param);
        Task<SearchResult> GetClassAttributes(GetParameter param);
        Task<SearchResult> GetProductLineAttributes(GetParameter param);
        Task<SearchResult> GetGradeAttributes(GetParameter param);
    }
}
