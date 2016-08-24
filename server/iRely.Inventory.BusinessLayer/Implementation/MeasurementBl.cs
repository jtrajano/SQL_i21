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
    public class MeasurementBl : BusinessLayer<tblICMeasurement>, IMeasurementBl
    {
        public MeasurementBl(IRepository db)
            : base(db)
        {
        }

        public override async Task<SearchResult> Search(GetParameter param)
        {
            var query = _db.GetQuery<tblICMeasurement>()
                .Filter(param, true);
            var data = await query.Execute(param, "intMeasurementId").ToListAsync();
            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
