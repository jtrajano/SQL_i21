using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemUOMBl : IBusinessLayer<tblICItemUOM>
    {
        Task<SearchResult> GetWeightUOMs(GetParameter param);
        Task<SearchResult> GetWeightVolumeUOMs(GetParameter param);
    }
}
