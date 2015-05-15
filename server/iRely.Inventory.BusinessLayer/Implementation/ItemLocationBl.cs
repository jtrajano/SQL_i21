﻿using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemLocationBl : BusinessLayer<tblICItemLocation>, IItemLocationBl 
    {
        #region Constructor
        public ItemLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
