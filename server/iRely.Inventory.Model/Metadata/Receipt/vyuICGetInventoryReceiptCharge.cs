using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptCharge
    {
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intContractId { get; set; }
        public string strContractNumber { get; set; }
        public int? intContractSeq { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public bool? ysnPrice { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public string strCurrency { get; set; }
        //   public int? intCent { get; set; }
        public string strTaxGroup { get; set; }
        public decimal? dblTax { get; set; }
        public string strReceiptNumber { get; set; }
        public DateTime? dtmReceiptDate { get; set; }
        public string strLocationName { get; set; }
        public string strBillOfLading { get; set; }
        public string strReceiptVendor { get; set; }
        public string strForexRateType { get; set; }
        public string strCostType { get; set; }
        public string strChargesLink { get; set; }
        public decimal? dblQuantity { get; set; }
        public int intConcurrencyId { get; set; }
        public int? intChargeId { get; set; }
	    public int? intCostUOMId { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public int? intSort { get; set; }
        public int? intTaxGroupId { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public int? intCostUnitMeasureId { get; set; }

        public tblICInventoryReceiptCharge tblICInventoryReceiptCharge { get; set; }
    }
}
