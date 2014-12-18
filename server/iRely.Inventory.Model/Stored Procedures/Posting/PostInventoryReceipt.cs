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
        public void PostInventoryReceipt(bool ysnRecap, string transactionId, int userId, int entityId) 
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReceipt @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEntityId",
                new SqlParameter("@ysnPost", true),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intUserId", userId),
                new SqlParameter("@intEntityId", entityId)
            );            
        }

        public void UnpostInventoryReceipt(bool ysnRecap, string transactionId, int userId, int entityId)
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReceipt @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEntityId",
                new SqlParameter("@ysnPost", false),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intUserId", userId),
                new SqlParameter("@intEntityId", entityId)
            );
        }
    }
}
