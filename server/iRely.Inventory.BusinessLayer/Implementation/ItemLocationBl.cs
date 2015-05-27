using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemLocationBl : BusinessLayer<tblICItemLocation>, IItemLocationBl 
    {
        #region Constructor
        public ItemLocationBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemLocation>()
                .Include(p => p.tblSMCompanyLocation)
                .Include(p => p.vyuAPVendor)
                .Include(p => p.tblSMCompanyLocationSubLocation)
                .Select(p => new ItemLocationVM
                {
                    intItemLocationId = p.intItemLocationId,
                    intItemId = p.intItemId,
                    intLocationId = p.intLocationId,
                    intCompanyLocationId = p.intLocationId,
                    strLocationName = p.tblSMCompanyLocation.strLocationName,
                    strLocationType = p.tblSMCompanyLocation.strLocationType,
                    intVendorId = p.intVendorId,
                    strVendorId = p.vyuAPVendor.strName,
                    strDescription = p.strDescription,
                    intCostingMethod = p.intCostingMethod,
                    intAllowNegativeInventory = p.intAllowNegativeInventory,
                    intSubLocationId = p.intSubLocationId,
                    strSubLocation = p.tblSMCompanyLocationSubLocation.strSubLocationName,
                    intStorageLocationId = p.intStorageLocationId,
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
