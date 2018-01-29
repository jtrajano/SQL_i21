using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryShipmentChargeTaxBl : BusinessLayer<tblICInventoryShipmentChargeTax>, IInventoryShipmentChargeTaxBl 
    {
        #region Constructor
        public InventoryShipmentChargeTaxBl(IInventoryRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetShipmentChargeTaxView(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryShipmentChargeTax>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryShipmentChargeTaxId").ToListAsync(param.cancellationToken);

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync(param.cancellationToken),
                summaryData = await query.ToAggregateAsync(param.aggregates)
            };
        }
    }
}
