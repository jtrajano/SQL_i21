﻿using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemNoteBl : BusinessLayer<tblICItemNote>, IItemNoteBl 
    {
        #region Constructor
        public ItemNoteBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
