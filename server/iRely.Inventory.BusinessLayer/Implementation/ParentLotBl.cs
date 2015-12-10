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
    public class ParentLotBl : BusinessLayer<tblICParentLot>, IParentLotBl 
    {
        #region Constructor
        public ParentLotBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
