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
        public int? DuplicateCategory(int inCategoryId)
        {
            var newCategoryId = new SqlParameter("@intNewCategoryId", SqlDbType.Int);
            newCategoryId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "EXEC dbo.uspICDuplicateCategory @intCategoryId, @intNewCategoryId OUTPUT",
                new SqlParameter("@intCategoryId", inCategoryId),
                newCategoryId
            );
            return (int)newCategoryId.Value;
        }
    }
}
