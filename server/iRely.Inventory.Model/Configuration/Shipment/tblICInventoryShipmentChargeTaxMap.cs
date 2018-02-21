using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class tblICInventoryShipmentChargeTaxMap : EntityTypeConfiguration<tblICInventoryShipmentChargeTax>
    {
        public tblICInventoryShipmentChargeTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeTaxId);

            // Table & Column Mappings
            this.ToTable("tblICInventoryShipmentChargeTax");
            this.Property(t => t.intInventoryShipmentChargeTaxId).HasColumnName("intInventoryShipmentChargeTaxId");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnTaxOnly).HasColumnName("ysnTaxOnly");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.dblQty).HasColumnName("dblQty");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
        }
    }
}
