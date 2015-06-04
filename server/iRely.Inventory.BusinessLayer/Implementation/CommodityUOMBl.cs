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
    public class CommodityUOMBl : BusinessLayer<tblICCommodityUnitMeasure>, ICommodityUOMBl 
    {
        #region Constructor
        public CommodityUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodityUnitMeasure>()
                .Include(p => p.tblICUnitMeasure)
                .Select(p => new CommodityUOMVM
                {
                    intCommodityUnitMeasureId = p.intCommodityUnitMeasureId,
                    intCommodityId = p.intCommodityId,
                    intUnitMeasureId = p.intUnitMeasureId,
                    dblUnitQty = p.dblUnitQty,
                    ysnStockUnit = p.ysnStockUnit,
                    ysnDefault = p.ysnDefault,
                    intSort = p.intSort,
                    strUnitMeasure = p.tblICUnitMeasure.strUnitMeasure
                })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityUnitMeasureId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
