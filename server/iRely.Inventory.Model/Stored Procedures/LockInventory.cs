using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Data.Entity.Infrastructure;
using System.Data.Entity.Core.Objects;


namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public void LockInventory(int InventoryCountId, bool ysnLock = true)
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICLockInventoryCount @intInventoryCountId, @ysnLock",
                new SqlParameter("@intInventoryCountId", InventoryCountId),
                new SqlParameter("@ysnLock", ysnLock)
                
            );
        }
    }
}
