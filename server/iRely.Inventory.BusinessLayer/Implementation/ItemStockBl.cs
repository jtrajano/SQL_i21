using iRely.Common;

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
            var query = _db.GetQuery<vyuICGetItemStockUOM>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetItemStockUOMForAdjustmentView(GetParameter param)
        {
            int? filterLocation = null;
            int? filterItemId = null; 

            // Get the filters 
            var filters = param.filter;

            foreach (var filter in filters)
            {
                if (filter.c == "intLocationId")
                {
                    int location;
                    if (Int32.TryParse(filter.v, out location))
                    {
                        filterLocation = location;
                    }                    
                }

                if (filter.c == "intItemId")
                {
                    int item;
                    if (Int32.TryParse(filter.v, out item))
                    {
                        filterItemId = item;
                    }
                }
            }

            var query = from x in _db.GetQuery<vyuICGetItemStockUOMForAdjustment>()
                        where (x.intLocationId == null || x.intLocationId == filterLocation) &&
                                x.intItemId == filterItemId                               
                        select x;

            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
