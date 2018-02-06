using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public interface IItemBundleBl : IBusinessLayer<tblICItemBundle>
    {
        Task<GetObjectResult> GetBundleComponents(GetParameter param, int intBundleItemId, int intLocationId);
    }
}
