using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class LotBl : BusinessLayer<tblICLot>, ILotBl 
    {
        #region Constructor
        public LotBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
