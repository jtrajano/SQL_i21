using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryCountDetailBl : BusinessLayer<tblICInventoryCountDetail>, IInventoryCountDetailBl
    {
        public InventoryCountDetailBl(IRepository db)
            : base(db)
        {
            _db = db;
            _db.ContextManager.Database.CommandTimeout = 120000;
        }
    }
}
