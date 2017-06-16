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
        public void ProcessBill(int receiptId, out int? newBill, out string newBills)
        {
            newBill = null;
            newBills = string.Empty;

            var receiptIdParam = new SqlParameter("intReceiptId", receiptId);
            var userId = new SqlParameter("@intUserId", iRely.Common.Security.GetEntityId());

            var outBillId = new SqlParameter("@intBillId", newBill);
            outBillId.Direction = System.Data.ParameterDirection.Output;
            outBillId.DbType = System.Data.DbType.Int32;
            outBillId.SqlDbType = System.Data.SqlDbType.Int;

            var outBillIds = new SqlParameter("@strBillIds", newBills);
            outBillIds.Direction = ParameterDirection.Output;
            outBillIds.DbType = DbType.String;
            outBillIds.Size = -1;
            outBillIds.SqlDbType = SqlDbType.NVarChar;

            this.Database.ExecuteSqlCommand(
                "uspICProcessToBill @intReceiptId, @intUserId, @intBillId OUTPUT, @strBillIds OUTPUT",
                receiptIdParam, 
                userId,
                outBillId,
                outBillIds
            );

            newBill = (int)outBillId.Value;
            newBills = outBillIds.Value.ToString();
        }
    }
}
