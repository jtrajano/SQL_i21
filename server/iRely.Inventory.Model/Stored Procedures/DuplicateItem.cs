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
        public int? DuplicateItem(int ItemId)
        {
            var newItemId = new SqlParameter("@NewItemId", SqlDbType.Int);
            newItemId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "EXEC dbo.uspICDuplicateItem @ItemId, @NewItemId OUTPUT",
                new SqlParameter("@ItemId", ItemId),
                newItemId
            );
            return (int)newItemId.Value;
        }
    }
}
