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
    public class ItemPOSCategoryBl : BusinessLayer<tblICItemPOSCategory>, IItemPOSCategoryBl 
    {
        #region Constructor
        public ItemPOSCategoryBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }

    public class ItemPOSSLABl : BusinessLayer<tblICItemPOSSLA>, IItemPOSSLABl
    {
        #region Constructor
        public ItemPOSSLABl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
