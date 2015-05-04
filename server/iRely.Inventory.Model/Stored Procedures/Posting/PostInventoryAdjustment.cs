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
        public void PostInventoryAdjustment(bool ysnRecap, string transactionId, int userId, int entityId) 
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEntityId",
                new SqlParameter("@ysnPost", true),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intUserId", userId),
                new SqlParameter("@intEntityId", entityId)
            );            
        }

        public void UnPostInventoryAdjustment(bool ysnRecap, string transactionId, int userId, int entityId)
        {
            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intUserId, @intEntityId",
                new SqlParameter("@ysnPost", false),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intUserId", userId),
                new SqlParameter("@intEntityId", entityId)
            );
        }

        public bool ValidateOutdatedStockOnHand(string transactionId)
        {
            var param_transactionId = new SqlParameter("@strTransactionId", transactionId);

            var param_passed = new SqlParameter();
            param_passed.ParameterName = "@ysnPassed";
            param_passed.Direction = ParameterDirection.Output;
            param_passed.SqlDbType = SqlDbType.Bit;
            
            this.Database.ExecuteSqlCommand(
                "dbo.uspICInventoryAdjustmentGetOutdatedStockOnHand @strTransactionId, @ysnPassed out",
                param_transactionId,
                param_passed
            );

            return Convert.ToBoolean(param_passed.Value);
        }

        public void UpdateOutdatedStockOnHand(string transactionId)
        {
            var param_transactionId = new SqlParameter("@strTransactionId", transactionId);

            this.Database.ExecuteSqlCommand(
                "dbo.uspICInventoryAdjustmentUpdatedOutdatedStockOnHand @strTransactionId",
                param_transactionId
            );
        }
    }
}
