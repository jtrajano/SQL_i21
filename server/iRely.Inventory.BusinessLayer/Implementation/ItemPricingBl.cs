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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
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
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
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

        public async Task<SearchResult> GetItemPricingLevel(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemPricingLevel>()
                .Include(p => p.tblICItem)
                .Include(p => p.tblICItemLocation)
                .Include(p => p.tblICItemUOM)
                .Include(p => p.tblSMCurrency)
                .Select(p => new ItemPricingLevelVM
                {
                    intItemPricingLevelId = p.intItemPricingLevelId,
                    intItemId = p.intItemId,
                    intItemLocationId = p.intItemLocationId,
                    strPriceLevel = p.strPriceLevel,
                    intItemUnitMeasureId = p.intItemUnitMeasureId,
                    dblUnit = p.dblUnit,
                    dblMin = p.dblMin,
                    dblMax = p.dblMax,
                    strPricingMethod = p.strPricingMethod,
                    dblAmountRate = p.dblAmountRate,
                    dblUnitPrice = p.dblUnitPrice,
                    strCommissionOn = p.strCommissionOn,
                    dblCommissionRate = p.dblCommissionRate,
                    intCurrencyId = p.intCurrencyId,
                    intSort = p.intSort,
                    strLocationName = p.tblICItemLocation.vyuICGetItemLocation.strLocationName,
                    intLocationId = p.tblICItemLocation.intLocationId,
                    strUnitMeasure = p.tblICItemUOM.tblICUnitMeasure.strUnitMeasure,
                    strUPC = p.tblICItemUOM.strUpcCode,
                    strCurrency = p.tblSMCurrency.strCurrency,
                    intConcurrencyId = p.intConcurrencyId
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemPricingLevelId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
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
