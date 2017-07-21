﻿using System;
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
        //public void PostInventoryAdjustment(bool ysnRecap, string transactionId, int entityId) 
        //{
        //    this.Database.ExecuteSqlCommand(
        //        "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId",
        //        new SqlParameter("@ysnPost", true),
        //        new SqlParameter("@ysnRecap", ysnRecap),
        //        new SqlParameter("@strTransactionId", transactionId),
        //        new SqlParameter("@intEntityUserSecurityId", entityId)
        //    );            
        //}
        public string PostInventoryAdjustment(bool ysnRecap, string transactionId, int entityId)
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", true),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value;
        }
        //public void UnPostInventoryAdjustment(bool ysnRecap, string transactionId, int entityId)
        //{
        //    this.Database.ExecuteSqlCommand(
        //        "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId",
        //        new SqlParameter("@ysnPost", false),
        //        new SqlParameter("@ysnRecap", ysnRecap),
        //        new SqlParameter("@strTransactionId", transactionId),
        //        new SqlParameter("@intEntityUserSecurityId", entityId)
        //    );
        //}

        public string UnPostInventoryAdjustment(bool ysnRecap, string transactionId, int entityId)
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryAdjustment @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", false),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value;
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
                "dbo.uspICInventoryAdjustmentUpdateOutdatedStockOnHand @strTransactionId",
                param_transactionId
            );
        }

        public bool ValidateOutdatedExpiryDate(string transactionId)
        {
            var param_transactionId = new SqlParameter("@strTransactionId", transactionId);

            var param_passed = new SqlParameter();
            param_passed.ParameterName = "@ysnPassed";
            param_passed.Direction = ParameterDirection.Output;
            param_passed.SqlDbType = SqlDbType.Bit;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICInventoryAdjustmentGetOutdatedExpiryDate @strTransactionId, @ysnPassed out",
                param_transactionId,
                param_passed
            );

            return Convert.ToBoolean(param_passed.Value);
        }

        public void UpdateOutdatedExpiryDate(string transactionId)
        {
            var param_transactionId = new SqlParameter("@strTransactionId", transactionId);

            this.Database.ExecuteSqlCommand(
                "dbo.uspICInventoryAdjustmentUpdateOutdatedExpiryDate @strTransactionId",
                param_transactionId
            );
        }

    }
}
