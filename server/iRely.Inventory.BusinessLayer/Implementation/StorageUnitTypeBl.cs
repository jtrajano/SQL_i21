using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class StorageUnitTypeBl : BusinessLayer<tblICStorageUnitType>, IStorageUnitTypeBl 
    {
        #region Constructor
        public StorageUnitTypeBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
