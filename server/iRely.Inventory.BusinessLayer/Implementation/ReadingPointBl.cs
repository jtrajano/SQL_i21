using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Common;

namespace iRely.Inventory.BusinessLayer
{
    public class ReadingPointBl : BusinessLayer<tblICReadingPoint>, IReadingPointBl
    {
        public ReadingPointBl(IRepository db)
            : base(db)
        {
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICReadingPoint>()
                .Filter(param, true);
            var data = await query.Execute(param, "intReadingPointId").ToListAsync();
            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
