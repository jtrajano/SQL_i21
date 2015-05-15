using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemVendorXrefBl : BusinessLayer<tblICItemVendorXref>, IItemVendorXrefBl
    {
        #region Constructor
        public ItemVendorXrefBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion
    }

    public class ItemCustomerXrefBl : BusinessLayer<tblICItemCustomerXref>, IItemCustomerXrefBl
    {
        #region Constructor
        public ItemCustomerXrefBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
