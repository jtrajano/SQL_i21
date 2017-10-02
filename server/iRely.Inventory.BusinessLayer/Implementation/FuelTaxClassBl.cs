﻿using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class FuelTaxClassBl : BusinessLayer<tblICFuelTaxClass>, IFuelTaxClassBl 
    {
        #region Constructor
        public FuelTaxClassBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
