using iRely.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentCharge : BaseEntity
    {
        public tblICInventoryShipmentCharge()
        {
            this.tblICInventoryShipmentChargeTaxes = new List<tblICInventoryShipmentChargeTax>();
        }
        public int intInventoryShipmentChargeId { get; set; }
        public int intInventoryShipmentId { get; set; }
        public int? intContractId { get; set; }
        public int? intContractDetailId { get; set; }
        public int? intChargeId { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblRate { get; set; }
        public int? intCostUOMId { get; set; }
        public int? intCurrencyId { get; set; }
        public decimal? dblAmount { get; set; }
        public decimal? dblAmountBilled { get; set; }
        public decimal? dblAmountPaid { get; set; }
        public decimal? dblAmountPriced { get; set; }
        public string strAllocatePriceBy { get; set; }
        public bool? ysnAccrue { get; set; }
        public int? intEntityVendorId { get; set; }
        public bool? ysnPrice { get; set; }
        public int? intSort { get; set; }
        public int? intForexRateTypeId { get; set; }
        public decimal? dblForexRate { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblQuantityBilled { get; set; }
        public decimal? dblQuantityPriced { get; set; }
        public int? intTaxGroupId { get; set; }
        public decimal? dblTax { get; set; }
        public decimal? dblAdjustedTax { get; set; }
        public string strChargesLink { get; set; }
        private string _contractNo;
        
        public tblICInventoryShipment tblICInventoryShipment { get; set; }
        public vyuICGetInventoryShipmentCharge vyuICGetInventoryShipmentCharge { get; set; }
        public ICollection<tblICInventoryShipmentChargeTax> tblICInventoryShipmentChargeTaxes { get; set; }
    }
}
