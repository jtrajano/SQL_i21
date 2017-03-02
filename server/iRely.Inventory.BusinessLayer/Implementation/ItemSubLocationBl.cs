using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using IdeaBlade.Linq;
using System;
using System.ComponentModel.DataAnnotations;

namespace iRely.Inventory.BusinessLayer
{
    public class ItemSubLocationBl : BusinessLayer<tblICItemSubLocation>, IItemSubLocationBl
    {
        public ItemSubLocationBl(IRepository repository)
            : base(repository)
        {

        }

        public async Task<SearchResult> GetItemSubLocations(GetParameter param)
        {
            var query = _db.GetQuery<vyuICItemSubLocations>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intItemSubLocationId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
