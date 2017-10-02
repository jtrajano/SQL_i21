﻿using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemCommodityCostBl : BusinessLayer<tblICItemCommodityCost>, IItemCommodityCostBl 
    {
        #region Constructor
        public ItemCommodityCostBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
