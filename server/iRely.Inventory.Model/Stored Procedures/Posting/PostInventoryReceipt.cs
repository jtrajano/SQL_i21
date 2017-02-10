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
        public string PostInventoryReceipt(bool ysnRecap, string transactionId, int entityId) 
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReceipt @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", true),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value; 
        }

        public string UnpostInventoryReceipt(bool ysnRecap, string transactionId, int entityId)
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReceipt @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", false),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value;
        }

        public string PostInventoryReturn(bool ysnRecap, string transactionId, int entityId)
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReturn @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", true),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value;
        }

        public string UnpostInventoryReturn(bool ysnRecap, string transactionId, int entityId)
        {
            var strBatchId = new SqlParameter("@strBatchId", SqlDbType.NVarChar);
            strBatchId.Size = 40;
            strBatchId.Direction = ParameterDirection.Output;

            this.Database.ExecuteSqlCommand(
                "dbo.uspICPostInventoryReturn @ysnPost, @ysnRecap, @strTransactionId, @intEntityUserSecurityId, @strBatchId OUTPUT",
                new SqlParameter("@ysnPost", false),
                new SqlParameter("@ysnRecap", ysnRecap),
                new SqlParameter("@strTransactionId", transactionId),
                new SqlParameter("@intEntityUserSecurityId", entityId),
                strBatchId
            );

            return (string)strBatchId.Value;
        }
    }
}
