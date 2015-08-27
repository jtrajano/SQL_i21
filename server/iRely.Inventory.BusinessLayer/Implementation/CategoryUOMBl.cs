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
    public class CategoryUOMBl : BusinessLayer<tblICCategoryUOM>, ICategoryUOMBl 
    {
        #region Constructor
        public CategoryUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICCategoryUOM>()
                .Include(p=> p.tblICUnitMeasure)
                .Select(p => new CategoryUOMVM { 
                    intCategoryUOMId = p.intCategoryUOMId,
                    intCategoryId = p.intCategoryId,
                    intUnitMeasureId = p.intUnitMeasureId,
                    dblUnitQty = p.dblUnitQty,
                    ysnStockUnit = p.ysnStockUnit,
                    ysnAllowPurchase = p.ysnAllowPurchase,
                    ysnAllowSale = p.ysnAllowSale,
                    ysnDefault = p.ysnDefault,
                    strUnitMeasure = p.tblICUnitMeasure.strUnitMeasure,
                    strUnitType = p.tblICUnitMeasure.strUnitType
                })
                .Filter(param, true);
            var data = await query.Execute(param, "intCategoryId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
