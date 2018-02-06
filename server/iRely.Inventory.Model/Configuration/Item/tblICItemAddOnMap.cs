using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemAddOnMap : EntityTypeConfiguration<tblICItemAddOn>
    {
        public tblICItemAddOnMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAddOnId);

            // Table & Column Mappings
            this.ToTable("tblICItemAddOn");
            this.Property(t => t.intItemAddOnId).HasColumnName("intItemAddOnId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intAddOnItemId).HasColumnName("intAddOnItemId");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");

            this.HasOptional(p => p.AddOnItem)
                .WithMany(p => p.AddOnItems)
                .HasForeignKey(p => p.intAddOnItemId);

            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemAddOns)
                .HasForeignKey(p => p.intItemUOMId);
        }
    }

    public class vyuICGetAddOnItemMap : EntityTypeConfiguration<vyuICGetAddOnItem>
    {
        public vyuICGetAddOnItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemAddOnId);

            // Table & Column Mappings
            this.ToTable("vyuICGetAddOnItem");
            this.Property(t => t.intItemAddOnId).HasColumnName("intItemAddOnId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.intAddOnItemId).HasColumnName("intAddOnItemId");
            this.Property(t => t.strAddOnItemNo).HasColumnName("strAddOnItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
        }
    }

    public class vyuICGetAddOnComponentStockMap : EntityTypeConfiguration<vyuICGetAddOnComponentStock>
    {
        public vyuICGetAddOnComponentStockMap()
        {
            this.HasKey(t => t.intParentKey);

            this.ToTable("vyuICGetAddOnComponentStock");
        }
    }
}
