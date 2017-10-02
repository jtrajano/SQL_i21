using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemPOSCategoryBl : BusinessLayer<tblICItemPOSCategory>, IItemPOSCategoryBl 
    {
        #region Constructor
        public ItemPOSCategoryBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }

    public class ItemPOSSLABl : BusinessLayer<tblICItemPOSSLA>, IItemPOSSLABl
    {
        #region Constructor
        public ItemPOSSLABl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
