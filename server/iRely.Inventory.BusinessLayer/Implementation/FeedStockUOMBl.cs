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
    public class FeedStockUOMBl : BusinessLayer<tblICRinFeedStockUOM>, IFeedStockUOMBl 
    {
        #region Constructor
        public FeedStockUOMBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICRinFeedStockUOM>()
               .Include(p => p.tblICUnitMeasure)
               .Select(p => new FeedStockUOMVM
               {
                    intRinFeedStockUOMId = p.intRinFeedStockUOMId,
                    intUnitMeasureId = p.intUnitMeasureId,
                    strRinFeedStockUOMCode = p.strRinFeedStockUOMCode,
                    strUnitMeasure = p.tblICUnitMeasure.strUnitMeasure
               })
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intRinFeedStockUOMId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };

        }
    }
}
