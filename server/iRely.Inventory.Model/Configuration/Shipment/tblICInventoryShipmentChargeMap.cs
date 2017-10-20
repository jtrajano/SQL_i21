using System;
using System.Collections.Generic;
using System.Data.Entity.ModelConfiguration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentChargeMap : EntityTypeConfiguration<tblICInventoryShipmentCharge>
    {
        public tblICInventoryShipmentChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentCharge");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.intContractDetailId).HasColumnName("intContractDetailId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocatePriceBy).HasColumnName("strAllocatePriceBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intForexRateTypeId).HasColumnName("intForexRateTypeId");
            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);

            this.HasOptional(p => p.vyuICGetInventoryShipmentCharge)
                .WithRequired(p => p.tblICInventoryShipmentCharge);
        }
    }
}
