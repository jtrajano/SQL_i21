using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemSubLocationBl : IBusinessLayer<tblICItemSubLocation>
    {
        Task<SearchResult> GetItemSubLocations(GetParameter param);
    }
}
