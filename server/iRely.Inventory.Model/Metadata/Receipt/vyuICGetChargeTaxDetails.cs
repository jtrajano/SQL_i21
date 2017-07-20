using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetChargeTaxDetails
    {
        public int? intKey { get; set; }
        public int? intInventoryReceiptChargeTaxId { get; set; }
        public int? intInventoryReceiptId { get; set; }
        public int? intChargeId { get; set; }
        public string strItemNo { get; set; }
        public string strTaxGroup { get; set; }
        public string strTaxCode { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
    }
}
