using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Threading.Tasks;
using iRely.Common;
using iRely.Inventory.Model;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryShipmentItemLotBl : BusinessLayer<tblICInventoryShipmentItemLot>, IInventoryShipmentItemLotBl
    {
        public InventoryShipmentItemLotBl(IInventoryRepository db)
            : base(db)
        {
            _db = db;
            _db.ContextManager.Database.CommandTimeout = 180000;
        }

        public async Task<SearchResult> SearchLots(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipmentItemLot>()
                .Filter(param, true);

            var data = await query.Execute(param, "intInventoryShipmentItemLotId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }

        public async Task<SearchResult> GetLots(int? intInventoryShipmentItemId)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipmentItemLot>()
                .Where(w => w.intInventoryShipmentItemId == intInventoryShipmentItemId);

            var data = await query.ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
                //summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
