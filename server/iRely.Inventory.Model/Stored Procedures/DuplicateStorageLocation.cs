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
        public int? DuplicateStorageLocation(int StorageLocationId)
        {
            var newStorageLocationId = new SqlParameter("@NewStorageLocationId", SqlDbType.Int);
            newStorageLocationId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "EXEC dbo.uspICDuplicateStorageLocation @StorageLocationId, @NewStorageLocationId OUTPUT",
                new SqlParameter("@StorageLocationId", StorageLocationId),
                newStorageLocationId
            );
            return (int)newStorageLocationId.Value;
        }
    }
}
