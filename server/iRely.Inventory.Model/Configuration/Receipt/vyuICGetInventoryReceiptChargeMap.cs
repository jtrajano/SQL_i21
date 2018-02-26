using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptChargeMap : EntityTypeConfiguration<vyuICGetInventoryReceiptCharge>
    {
        public vyuICGetInventoryReceiptChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptCharge");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.strContractNumber).HasColumnName("strContractNumber");
            this.Property(t => t.intContractSeq).HasColumnName("intContractSeq");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocateCostBy).HasColumnName("strAllocateCostBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.strReceiptNumber).HasColumnName("strReceiptNumber");
            this.Property(t => t.dtmReceiptDate).HasColumnName("dtmReceiptDate");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strBillOfLading).HasColumnName("strBillOfLading");
            this.Property(t => t.strReceiptVendor).HasColumnName("strReceiptVendor");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.strChargesLink).HasColumnName("strChargesLink");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.dblAmountBilled).HasColumnName("dblAmountBilled");
            this.Property(t => t.dblAmountPaid).HasColumnName("dblAmountPaid");
            this.Property(t => t.dblAmountPriced).HasColumnName("dblAmountPriced");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate");
            this.Property(t => t.intCostUnitMeasureId).HasColumnName("intCostUnitMeasureId");
        // this.Property(t => t.strCurrency).HasColumnName("strCurrency");
        // this.Property(t => t.intCent).HasColumnName("intCent");

        }
    }    
}
