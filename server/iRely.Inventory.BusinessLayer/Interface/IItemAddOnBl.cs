using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemAddOnBl : IBusinessLayer<tblICItemAddOn>
    {
        Task<GetObjectResult> GetItemAddOns(int intItemId, int intItemUOMId, int intLocationId, decimal? dblQuantity);
    }
}
