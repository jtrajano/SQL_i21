using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryReceiptChargeTaxBl : BusinessLayer<tblICInventoryReceiptChargeTax>, IInventoryReceiptChargeTaxBl 
    {
        #region Constructor
        public InventoryReceiptChargeTaxBl(IRepository db)
            : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetReceiptChargeTaxView(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptChargeTax>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryReceiptChargeTaxId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
