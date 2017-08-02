using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public async Task<decimal> CalculateGrossQtyRatio(int intItemUOMId, int intGrossUOMId, decimal dblQty, decimal dblProposedQty, decimal dblProposedGrossQty)
        {
            var _intItemUOMId = new SqlParameter("@intItemUOMId", intItemUOMId);
            var _intGrossUOMId = new SqlParameter("@intGrossUOMId", intGrossUOMId);
            var _dblQty = CreateDecimalParam("@dblQty", dblQty);
            var _dblProposedQty = CreateDecimalParam("@dblProposedQty", dblProposedQty);
            var _dblProposedGrossQty = CreateDecimalParam("@dblProposedGrossQty", dblProposedGrossQty);

            var output = await Database.SqlQuery<decimal>("SELECT ISNULL(dbo.fnICCalculateGrossQtyRatio(@intItemUOMId, @intGrossUOMId, @dblQty, @dblProposedQty, @dblProposedGrossQty), 0.00) as dblRatio",
                _intItemUOMId, _intGrossUOMId, _dblQty, _dblProposedQty, _dblProposedGrossQty).FirstOrDefaultAsync();
            return output;
        }

        private SqlParameter CreateDecimalParam(string name, decimal value)
        {
            var param = new SqlParameter(name, value);
            param.Scale = 20;
            param.Precision = 38;
            param.SqlDbType = System.Data.SqlDbType.Decimal;
            param.DbType = System.Data.DbType.Decimal;

            return param;
        }
    }
}
