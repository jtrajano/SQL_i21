using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemFactoryBl : IBusinessLayer<tblICItemFactory>
    {
        Task<SearchResult> SearchItemFactoryManufacturingCells(GetParameter param);
        
    }

    public interface IItemOwnerBl : IBusinessLayer<tblICItemOwner>
    {
        
    }
}
