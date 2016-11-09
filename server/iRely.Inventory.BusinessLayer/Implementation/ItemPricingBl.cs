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
    public class ItemPricingBl : BusinessLayer<tblICItemPricing>, IItemPricingBl 
    {
        #region Constructor
        public ItemPricingBl(IRepository db) : base(db)
        {
            _db = db;
            _db.ContextManager.Database.CommandTimeout = 60000;
        }
        #endregion

        public async Task<SearchResult> GetItemPricingViews(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemPricing>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetItemStockPricingViews(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemPricing>()
                .Filter(param, true)
                .Where(p => p.ysnStockUnit == true);
            var data = await query.ExecuteProjection(param, "intItemId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }

    public class ItemPricingLevelBl : BusinessLayer<tblICItemPricingLevel>, IItemPricingLevelBl
    {
        #region Constructor
        public ItemPricingLevelBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

    }

    public class ItemSpecialPricingBl : BusinessLayer<tblICItemSpecialPricing>, IItemSpecialPricingBl
    {
        #region Constructor
        public ItemSpecialPricingBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

    }
}
