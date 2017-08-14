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
        public async Task<int> ValidateSubLocationChange(int storageLocationId, int? newSubLocationId)
        {
            var storageLocationIdParam = new SqlParameter("@intStorageLocationId", storageLocationId);
            var newSubLocationIdParam = new SqlParameter("@intNewSubLocationId", newSubLocationId);
            if (newSubLocationId == null) newSubLocationIdParam.Value = DBNull.Value; 
            return await this.Database.ExecuteSqlCommandAsync(
                "dbo.uspICValidateSubLocationChange @intStorageLocationId, @intNewSubLocationId",
                storageLocationIdParam,
                newSubLocationIdParam
            );
        }
    }
}
