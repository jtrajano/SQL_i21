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
        public async Task<int> RebuildInventory(DateTime? startDate, string itemNo, bool isPeriodic = true, bool generateBillGLEntries = false, int? userId = null)
        {
            SqlParameter paramStrNo = string.IsNullOrEmpty(itemNo) ? new SqlParameter("@strItemNo", DBNull.Value)  : new SqlParameter("@strItemNo", itemNo);
            this.Database.CommandTimeout = 120000;
            return await this.Database.ExecuteSqlCommandAsync(
                "dbo.uspICRebuildInventoryValuation @dtmStartDate, @strItemNo, @isPeriodic, @ysnRegenerateBillGLEntries, @intUserId",
                new SqlParameter("@dtmStartDate", startDate),
                paramStrNo,
                new SqlParameter("@isPeriodic", isPeriodic),
                new SqlParameter("@ysnRegenerateBillGLEntries", generateBillGLEntries),
                new SqlParameter("@intUserId", userId)
            );
        }
    }
}
