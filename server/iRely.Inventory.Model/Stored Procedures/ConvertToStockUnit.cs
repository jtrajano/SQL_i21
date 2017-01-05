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
        public int ConvertItemToNewStockUnit(int? ItemId, int? ItemUOMId)
        {
            return this.Database.ExecuteSqlCommand(
                "dbo.uspICChangeItemStockUOM @intItemId, @NewStockItemUOMId, @intEntitySecurityUserId",
                new SqlParameter("@intItemId", ItemId),
                new SqlParameter("@NewStockItemUOMId", ItemUOMId),
                new SqlParameter("@intEntitySecurityUserId", iRely.Common.Security.GetEntityId())
            );
        }
    }
}
