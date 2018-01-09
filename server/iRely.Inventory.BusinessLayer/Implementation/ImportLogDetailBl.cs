using iRely.Common;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using System.Data.Entity;

namespace iRely.Inventory.BusinessLayer
{
    public class ImportLogDetailBl : BusinessLayer<tblICImportLogDetail>, IImportLogDetailBl
    {
        public ImportLogDetailBl(IInventoryRepository db) : base(db)
        {
        
        }

        public async Task<SearchResult> SearchImportLogDetails(GetParameter param)
        {
            var query = _db.ContextManager.Set<tblICImportLogDetail>().Filter(param, true);
            var data = await query.ExecuteProjection(param, "intImportLogDetailId", "ASC").ToListAsync(param.cancellationToken);
            var response = new SearchResult()
            {
                data = data.AsQueryable(),
                success = true,
                total = await query.CountAsync(param.cancellationToken)
            };
            return response;
        }
    }
}
