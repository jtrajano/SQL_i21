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
    public class StorageLocationBl : BusinessLayer<tblICStorageLocation>, IStorageLocationBl 
    {
        #region Constructor
        public StorageLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion
    }
}
