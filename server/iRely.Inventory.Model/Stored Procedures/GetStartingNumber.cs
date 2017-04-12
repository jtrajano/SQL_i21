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
        public string GetStartingNumber(int transactionType, int? locationId)
        {
            var param_startingNumberId = new SqlParameter("@intStartingNumberId", transactionType);
            var param_locationId = new SqlParameter("@intCompanyLocationId", locationId);

            var param_transactionId = new SqlParameter();
            param_transactionId.ParameterName = "@strID";
            param_transactionId.Direction = ParameterDirection.Output;
            param_transactionId.SqlDbType = SqlDbType.NVarChar;
            param_transactionId.Size = 40;

            this.Database.ExecuteSqlCommand(
                "dbo.uspSMGetStartingNumber @intStartingNumberId, @strID out, @intCompanyLocationId",
                param_startingNumberId,
                param_transactionId,
                param_locationId
            );

            return Convert.ToString(param_transactionId.Value);
        }
    }
}
