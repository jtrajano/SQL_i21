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

        public override async Task<BusinessResult<tblICStorageUnitType>> SaveAsync(bool continueOnConflict)
        {
            var result = await base.SaveAsync(continueOnConflict).ConfigureAwait(false);
            if (result.message.status == Error.OtherException && result.message.statusText.ToString().Contains("Cannot insert duplicate key"))
            {
                result.message.statusText = "Storage Unit Type must be unique.";
            }
            return result;
        }
    }
}
