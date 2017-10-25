using iRely.Common;
using iRely.Inventory.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemLicenseBl : BusinessLayer<tblICItemLicense>, IItemLicenseBl
    {
        #region Constructor
        public ItemLicenseBl(IInventoryRepository db) :base (db)
        {
            _db = db;
        }
        #endregion

        #region Get Methods
        public async Task<GetObjectResult> GetItemLicense(GetParameter param)
        {
            var query = _db.GetQuery<vyuICItemLicense>().Filter(param, true);
            var key = Methods.GetPrimaryKey<vyuICItemLicense>(_db.ContextManager);

            return new GetObjectResult()
            {
                data = await query.Execute(param, key, "DESC").ToListAsync(param.cancellationToken).ConfigureAwait(false),
                total = await query.CountAsync(param.cancellationToken).ConfigureAwait(false)
            };
        }
        #endregion
    }
}
