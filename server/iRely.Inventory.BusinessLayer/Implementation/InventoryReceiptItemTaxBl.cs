using iRely.Common;
using iRely.Inventory.Model;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class InventoryReceiptItemTaxBl : BusinessLayer<tblICInventoryReceiptItemTax>, IInventoryReceiptItemTaxBl 
    {
        #region Constructor
        public InventoryReceiptItemTaxBl(IRepository db) : base(db)
        {
            _db = db;
        }
        #endregion

        public async Task<SearchResult> GetReceiptItemTaxView(GetParameter param)
        {
            var query = _db.GetQuery<vyuICGetInventoryReceiptItemTax>()
                .Filter(param, true);
            var data = await query.ExecuteProjection(param, "intInventoryReceiptItemTaxId").ToListAsync();

            return new SearchResult()
            {
                data = data.AsQueryable(),
                total = await query.CountAsync()
            };
        }
    }
}
