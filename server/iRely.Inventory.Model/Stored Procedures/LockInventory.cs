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
        public void LockInventory(int InventoryCountId)
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICLockInventoryCount @intInventoryCountId",
                new SqlParameter("@intInventoryCountId", InventoryCountId)
            );
        }
    }
}
