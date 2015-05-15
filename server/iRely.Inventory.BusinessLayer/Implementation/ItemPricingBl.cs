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
    public class ItemPricingBl : BusinessLayer<tblICItemPricing>, IItemPricingBl 
    {
        #region Constructor
        public ItemPricingBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetItemPricingViews(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetItemPricing>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetItemPricingLevels(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemPricingLevel>()
                .Include("tblICItemUOM.tblICUnitMeasure")
                .Include("tblICItemLocation.tblSMCompanyLocation")
                .Filter(param, true);
            var data = await query.ExecuteProjection(param).ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }

        public async Task<SearchResult> GetItemSpecialPricings(GetParameter param)
        {
            var query = _db.GetQuery<tblICItemSpecialPricing>()
                .Include("tblICItemUOM.tblICUnitMeasure")
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
