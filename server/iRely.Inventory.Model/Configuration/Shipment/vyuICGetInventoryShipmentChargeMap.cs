using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryShipmentChargeMap : EntityTypeConfiguration<vyuICGetInventoryShipmentCharge>
    {
        public vyuICGetInventoryShipmentChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryShipmentCharge");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.intContractDetailId).HasColumnName("intContractDetailId");
            this.Property(t => t.strContractNumber).HasColumnName("strContractNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.dblAmountBilled).HasColumnName("dblAmountBilled").HasPrecision(18, 6);
            this.Property(t => t.dblAmountPaid).HasColumnName("dblAmountPaid").HasPrecision(18, 6);
            this.Property(t => t.dblAmountPriced).HasColumnName("dblAmountPriced").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strAllocatePriceBy).HasColumnName("strAllocatePriceBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strForexRateType).HasColumnName("strForexRateType");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.strCostType).HasColumnName("strCostType");
            this.Property(t => t.strChargesLink).HasColumnName("strChargesLink");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
        }
    }
}
