using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetShipmentChargeTaxDetails
    {
        public int intInventoryShipmentChargeTaxId { get; set; }
        public int? intInventoryShipmentChargeId { get; set; }
        public int? intInventoryShipmentId { get; set; }
        public int? intChargeId { get; set; }
        public string strItemNo { get; set; }
        public string strTaxGroup { get; set; }
        public string strTaxClass { get; set; }
        public string strTaxCode { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblCost { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
    }
}
