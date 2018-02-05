using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentCharge
    {
        public int intInventoryShipmentChargeId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public string strContractNumber { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strChargesLink { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public int? intCurrencyId { get; set; }
        public string strCurrency { get; set; }
        public int? intOnCostTypeId { get; set; }
        public bool? ysnPrice { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public decimal? dblTax { get; set; }
        public string strAllocatePriceBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strForexRateType { get; set; }
        public decimal? dblQuantity { get; set; }
        public int? intTaxGroupId { get; set; }
        public string strTaxGroup { get; set; }
        public string strCostType { get; set; }
        public int intConcurrencyId { get; set; }
        public tblICInventoryShipmentCharge tblICInventoryShipmentCharge { get; set; }
    }
}
