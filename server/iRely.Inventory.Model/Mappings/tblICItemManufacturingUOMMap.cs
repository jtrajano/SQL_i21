using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemManufacturingUOMMap : EntityTypeConfiguration<tblICItemManufacturingUOM>
    {
        public tblICItemManufacturingUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemManufacturingUOMId);

            // Table & Column Mappings
            this.ToTable("tblICItemManufacturingUOM");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemManufacturingUOMId).HasColumnName("intItemManufacturingUOMId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemManufacturingUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }

}
