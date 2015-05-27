﻿using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;


namespace iRely.Inventory.BusinessLayer
{
    public class FeedStockCodeBl : BusinessLayer<tblICRinFeedStock>, IFeedStockCodeBl 
    {
        #region Constructor
        public FeedStockCodeBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
