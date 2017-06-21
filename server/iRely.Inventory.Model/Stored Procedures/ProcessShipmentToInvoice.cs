using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        public async Task<int?> ProcessShipmentToInvoice(int shipmentId)
        {
            var shipmentIdParam = new SqlParameter("@ShipmentId", shipmentId);
            var securityUserIdParam = new SqlParameter("@UserId", iRely.Common.Security.GetEntityId());

            var newInvoiceIdOutParam = new SqlParameter("@NewInvoiceId", null);
            newInvoiceIdOutParam.Direction = System.Data.ParameterDirection.Output;
            newInvoiceIdOutParam.DbType = System.Data.DbType.Int32;
            newInvoiceIdOutParam.SqlDbType = System.Data.SqlDbType.Int;

            await this.Database.ExecuteSqlCommandAsync(
                "uspARCreateInvoiceFromShipment @ShipmentId, @UserId, @NewInvoiceId OUTPUT",
                shipmentIdParam,
                securityUserIdParam,
                newInvoiceIdOutParam
            );

            return newInvoiceIdOutParam.Value != DBNull.Value ? (int?)newInvoiceIdOutParam.Value : null; 
        }
    }
}
