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
    public class CommodityBl : BusinessLayer<tblICCommodity>, ICommodityBl 
    {
        #region Constructor
        public CommodityBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        /// <summary>
        /// Get Compact version of Commodity Details
        /// </summary>
        /// <param name="param"></param>
        /// <returns></returns>
        public async Task<SearchResult> GetCompactCommodities(GetParameter param)
        {
            var query = _db.GetQuery<tblICCommodity>()
                .Include("tblICCommodityUnitMeasures.tblICUnitMeasure")                
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intCommodityId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
