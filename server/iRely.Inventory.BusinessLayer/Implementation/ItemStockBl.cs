using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using System.Data.SqlClient;

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

        public async Task<SearchResult> SearchItemStockUOMs(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStockUOM>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
        
        public async Task<SearchResult> SearchItemStockUOMViewTotals(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStockUOMTotals>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetLocationStockOnHand(int intLocationId, int intItemId)
        {
            var query = _db.GetQuery<vyuICGetItemStockUOM>()
                .Where(w => w.intLocationId == intLocationId && w.intItemId == intItemId && w.ysnStockUnit == true)
                .GroupBy(o => o.intLocationId)
                .Select(g => new { dblOnHand = g.Sum(i => i.dblOnHand) });
            var data = await query.ToListAsync();

            return new SearchResult() 
            {
                data = query.AsQueryable()
            };
        }

        public async Task<SearchResult> SearchItemStockUOMForAdjustment(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemStockUOMForAdjustment>()
                        .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
