using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetChargeTaxDetailsMap : EntityTypeConfiguration<vyuICGetChargeTaxDetails>
    {
        public vyuICGetChargeTaxDetailsMap()
        {
            // Primary Key
            this.HasKey(t => t.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetChargeTaxDetails");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intInventoryReceiptChargeTaxId).HasColumnName("intInventoryReceiptChargeTaxId");
            this.Property(t => t.intInventoryReceiptChargeId).HasColumnName("intInventoryReceiptChargeId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intChargeId).HasColumnName("intChargeId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.strTaxClass).HasColumnName("strTaxClass");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate");
            this.Property(t => t.dblTax).HasColumnName("dblTax");
            this.Property(t => t.dblQty).HasColumnName("dblQty");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
        }
    }
}
