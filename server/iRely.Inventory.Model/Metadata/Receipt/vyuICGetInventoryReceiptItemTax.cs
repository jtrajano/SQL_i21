using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemTax
    {
        public int intInventoryReceiptItemTaxId { get; set; }
        public int intInventoryReceiptItemId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public int? intTaxClassId { get; set; }
        public string strTaxClass { get; set; }
        public int? intTaxCodeId { get; set; }
        public string strTaxCode { get; set; }
        public string strTaxableByOtherTaxes { get; set; }
        public string strCalculationMethod { get; set; }
        public decimal? dblRate { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public int? intTaxAccountId { get; set; }
        public bool? ysnTaxAdjusted { get; set; }
        public bool? ysnTaxOnly { get; set; }
        public bool? ysnSeparateOnInvoice { get; set; }
        public bool? ysnCheckoffTax { get; set; }
        public int? intSort { get; set; }
        public decimal? dblQty { get; set; }
        public decimal? dblCost { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
    }
}
