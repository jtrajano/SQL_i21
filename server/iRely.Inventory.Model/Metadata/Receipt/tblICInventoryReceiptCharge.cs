using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptCharge : BaseEntity
    {
        public tblICInventoryReceiptCharge()
        {
            this.tblICInventoryReceiptChargeTaxes = new List<tblICInventoryReceiptChargeTax>();
        }
        public int intInventoryReceiptChargeId { get; set; }
        public int intInventoryReceiptId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public decimal? dblAmount { get; set; }
        public string strAllocateCostBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public string strChargeEntity { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public int? intSort { get; set; }
        public int? intCurrencyId { get; set; }
        //     public decimal? dblExchangeRate { get; set; }
        //     public int? intCent { get; set; }
        public bool? ysnSubCurrency { get; set; }
        public decimal? dblTax { get; set; }
        public int? intTaxGroupId { get; set; }

        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public decimal? dblQuantity { get; set; }
        public string strChargesLink { get; set; }

        public tblICInventoryReceipt tblICInventoryReceipt { get; set; }
        public vyuICGetInventoryReceiptCharge vyuICGetInventoryReceiptCharge { get; set; }
        public ICollection<tblICInventoryReceiptChargeTax> tblICInventoryReceiptChargeTaxes { get; set; }
    }

}
