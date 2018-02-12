using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class tblICInventoryReceiptChargeMap : EntityTypeConfiguration<tblICInventoryReceiptCharge>
    {
        public tblICInventoryReceiptChargeMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptChargeId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryReceiptCharge");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intContractId).HasColumnName("intContractId");
            this.Property(t => t.intContractDetailId).HasColumnName("intContractDetailId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intEntityVendorId).HasColumnName("intEntityVendorId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.strAllocateCostBy).HasColumnName("strAllocateCostBy");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strChargeEntity).HasColumnName("strChargeEntity");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.dblTax).HasColumnName("dblTax");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            // this.Property(t => t.dblExchangeRate).HasColumnName("dblExchangeRate");
            // this.Property(t => t.intCent).HasColumnName("intCent");

            this.Property(t => t.dblForexRate).HasColumnName("dblForexRate").HasPrecision(18, 6);
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(18, 6);
            this.Property(t => t.strChargesLink).HasColumnName("strChargesLink");

            //this.HasOptional(p => p.vyuICGetInventoryReceiptCharge)
            //    .WithRequired(p => p.tblICInventoryReceiptCharge);
        }
    }   
}
