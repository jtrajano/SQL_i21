using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity.ModelConfiguration;
using System.ComponentModel.DataAnnotations.Schema;

namespace iRely.Inventory.Model
{
    public class vyuICGetShipmentChargeTaxDetailsMap : EntityTypeConfiguration<vyuICGetShipmentChargeTaxDetails>
    {
        public vyuICGetShipmentChargeTaxDetailsMap()
        {
            // Primary Key
            this.HasKey(t => t.intInventoryShipmentChargeTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetShipmentChargeTaxDetails");
            this.Property(t => t.intInventoryShipmentChargeTaxId).HasColumnName("intInventoryShipmentChargeTaxId");
            this.Property(t => t.intInventoryShipmentChargeId).HasColumnName("intInventoryShipmentChargeId");
            this.Property(t => t.intInventoryShipmentId).HasColumnName("intInventoryShipmentId");
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
            this.Property(t => t.ysnCheckoffTax).HasColumnName("ysnCheckoffTax");
            this.Property(t => t.ysnTaxAdjusted).HasColumnName("ysnTaxAdjusted");
            Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
        }
    }
}
