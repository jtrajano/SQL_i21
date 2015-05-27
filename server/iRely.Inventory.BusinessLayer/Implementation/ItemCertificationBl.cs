using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemCertificationBl : BusinessLayer<tblICItemCertification>, IItemCertificationBl 
    {
        #region Constructor
        public ItemCertificationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
