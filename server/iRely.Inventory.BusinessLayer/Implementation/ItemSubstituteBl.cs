using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemSubstituteBl : BusinessLayer<tblICItemSubstitute>, IItemSubstituteBl 
    {
        #region Constructor
        public ItemSubstituteBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
