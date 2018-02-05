using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetInventoryReceiptItemTaxMap : EntityTypeConfiguration<vyuICGetInventoryReceiptItemTax>
    {
        public vyuICGetInventoryReceiptItemTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryReceiptItemTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryReceiptItemTax");
            this.Property(t => t.intInventoryReceiptItemTaxId).HasColumnName("intInventoryReceiptItemTaxId");
            this.Property(t => t.intInventoryReceiptItemId).HasColumnName("intInventoryReceiptItemId");
            this.Property(t => t.intInventoryReceiptId).HasColumnName("intInventoryReceiptId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intTaxGroupId).HasColumnName("intTaxGroupId");
            this.Property(t => t.strTaxGroup).HasColumnName("strTaxGroup");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxClass).HasColumnName("strTaxClass");
            this.Property(t => t.intTaxCodeId).HasColumnName("intTaxCodeId");
            this.Property(t => t.strTaxCode).HasColumnName("strTaxCode");
            this.Property(t => t.strTaxableByOtherTaxes).HasColumnName("strTaxableByOtherTaxes");
            this.Property(t => t.strCalculationMethod).HasColumnName("strCalculationMethod");
            this.Property(t => t.dblRate).HasColumnName("dblRate").HasPrecision(18, 6);
            this.Property(t => t.dblTax).HasColumnName("dblTax").HasPrecision(18, 6);
            this.Property(t => t.dblAdjustedTax).HasColumnName("dblAdjustedTax").HasPrecision(18, 6);
            this.Property(t => t.intTaxAccountId).HasColumnName("intTaxAccountId");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            this.Property(t => t.ysnTaxOnly).HasColumnName("ysnTaxOnly");
            this.Property(t => t.ysnSeparateOnInvoice).HasColumnName("ysnSeparateOnInvoice");
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.dblQty).HasColumnName("dblQty");
            this.Property(t => t.dblCost).HasColumnName("dblCost");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
        }
    }
}
