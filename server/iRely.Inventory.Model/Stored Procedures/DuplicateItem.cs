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
        public void DuplicateItem(int ItemId, out int? NewItemId)
        {
            int? intNewId = null;
            var outParam = new SqlParameter("@NewItemId", intNewId);
            outParam.Direction = ParameterDirection.Output;
            outParam.DbType = DbType.Int32;
            this.Database.ExecuteSqlCommand(
                "dbo.uspICDuplicateItem @ItemId, @NewItemId",
                new SqlParameter("@ItemId", ItemId),
                outParam
            );
            NewItemId = intNewId;
        }
    }
}
