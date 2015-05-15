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
    public class UnitMeasureBl : BusinessLayer<tblICUnitMeasure>, IUnitMeasureBl 
    {
        #region Constructor
        public UnitMeasureBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetPackedUOMs(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetPackedUOM>()
                .Where(p => p.strUnitType == "Packed")
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
