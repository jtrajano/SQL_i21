using iRely.Common;
using iRely.GlobalComponentEngine.BusinessLayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemStockBl : BusinessLayer<tblICItemStock>, IItemStockBl 
    {
        #region Constructor
        public ItemStockBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetItemStockUOMView(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemStock>()
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
