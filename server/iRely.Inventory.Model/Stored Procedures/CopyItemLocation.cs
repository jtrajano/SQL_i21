using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public int CopyItemLocation(int intSourceItemId, string strDestinationItemIds, int intEntityUserSecurityId)
        {
            return this.Database.ExecuteSqlCommand(
                "dbo.uspICCopyItemLocation @intSourceItemId, @strDestinationItemIds, @intEntityUserSecurityId",
                new SqlParameter("@intSourceItemId", intSourceItemId),
                new SqlParameter("@strDestinationItemIds", strDestinationItemIds),
                new SqlParameter("@intEntityUserSecurityId", intEntityUserSecurityId) 
            );
        }
    }
}
