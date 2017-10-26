using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICInventoryReceiptTotals : BaseEntity
    {
        public int intInventoryReceiptId { get; set; }    
        public decimal? dblTotalCharge { get; set; }
        public decimal? dblTotalChargeTax { get; set; }
        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
    }
}
