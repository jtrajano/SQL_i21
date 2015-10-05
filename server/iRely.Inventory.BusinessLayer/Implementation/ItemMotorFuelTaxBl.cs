using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemMotorFuelTaxBl : BusinessLayer<tblICItemMotorFuelTax>, IItemMotorFuelTaxBl 
    {
        #region Constructor
        public ItemMotorFuelTaxBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
