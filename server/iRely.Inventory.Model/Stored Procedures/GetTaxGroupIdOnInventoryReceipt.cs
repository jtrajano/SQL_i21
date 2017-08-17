using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class TaxGroupOnInventoryReceipt {
        public int? intTaxGroupId;
        public string strTaxGroupId; 
    }

    public partial class InventoryEntities : DbContext
    {
        public TaxGroupOnInventoryReceipt GetTaxGroupIdOnInventoryReceipt(int receiptId)
        {
            int? newTaxGroupId = null;
            string newTaxGroupName = null;

            var taxGroupOnInventoryReceipt = new TaxGroupOnInventoryReceipt();

            var idParameter = new SqlParameter("@ReceiptId", receiptId);

            var outIntTaxGroupIdParam = new SqlParameter("@intTaxGroupId", newTaxGroupId);
            outIntTaxGroupIdParam.Direction = System.Data.ParameterDirection.Output;
            outIntTaxGroupIdParam.DbType = System.Data.DbType.Int32;
            outIntTaxGroupIdParam.SqlDbType = System.Data.SqlDbType.Int;

            var outStrTaxGroup = new SqlParameter("@strTaxGroup", newTaxGroupName);
            outStrTaxGroup.Direction = System.Data.ParameterDirection.Output;
            outStrTaxGroup.DbType = System.Data.DbType.String;
            outStrTaxGroup.SqlDbType = System.Data.SqlDbType.NVarChar;
            outStrTaxGroup.Size = 50;

            this.Database.ExecuteSqlCommand(
                "uspICGetTaxGroupIdOnInventoryReceipt @ReceiptId, @intTaxGroupId OUTPUT, @strTaxGroup OUTPUT"
                , idParameter
                , outIntTaxGroupIdParam
                , outStrTaxGroup
            );

            if (outIntTaxGroupIdParam.Value == DBNull.Value)
            {
                taxGroupOnInventoryReceipt.intTaxGroupId = null;
            }
            else {
                taxGroupOnInventoryReceipt.intTaxGroupId = (int)outIntTaxGroupIdParam.Value;
            }

            if (outStrTaxGroup.Value == DBNull.Value)
            {
                taxGroupOnInventoryReceipt.strTaxGroupId = String.Empty;
            }
            else {
                taxGroupOnInventoryReceipt.strTaxGroupId = (string)outStrTaxGroup.Value;
            }
                

            return taxGroupOnInventoryReceipt; 
        }
    }
}
