using iRely.Common;

using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

using iRely.Inventory.Model;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class LotBl : BusinessLayer<tblICLot>, ILotBl 
    {
        #region Constructor
        public LotBl(IRepository db) : base(db)
        {
            _db = db;
        }

        public async Task<SearchResult> GetLots(GetParameter param)
        {
            var query = _db.GetQuery<vyuICItemLot>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "strItemNo", "ASC").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
        #endregion

        public async Task<SearchResult> GetHistory(GetParameter param)
        {
            var query = _db.GetQuery<vyuICLotHistory>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "dtmDate", "DESC").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
