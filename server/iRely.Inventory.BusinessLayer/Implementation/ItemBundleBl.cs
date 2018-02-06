using iRely.Common;
using System.Data.Entity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemBundleBl : BusinessLayer<tblICItemBundle>, IItemBundleBl 
    {
        #region Constructor
        public ItemBundleBl(IInventoryRepository db) : base(db)
        {
            _db = db;
        }
        #endregion


        #region Custom Get Methods
        public async Task<GetObjectResult> GetBundleComponents(GetParameter param, int intBundleItemId, int intLocationId)
        {
            var query = _db.GetQuery<vyuICGetBundleItemStock>().Filter(param, true).Where(w => w.intBundleItemId == intBundleItemId && w.intLocationId == intLocationId);
            var key = Methods.GetPrimaryKey<vyuICGetBundleItemStock>(_db.ContextManager);

            return new GetObjectResult()
            {
                data = await query.Execute(param, key, "DESC").ToListAsync(param.cancellationToken).ConfigureAwait(false),
                total = await query.CountAsync(param.cancellationToken)
            };
        }
        #endregion
    }
}
