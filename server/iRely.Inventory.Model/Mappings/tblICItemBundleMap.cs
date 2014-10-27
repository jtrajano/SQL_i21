using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemBundleMap : EntityTypeConfiguration<tblICItemBundle>
    {
        public tblICItemBundleMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemBundleId);

            // Table & Column Mappings
            this.ToTable("tblICItemBundle");
            this.Property(t => t.dblPrice).HasColumnName("dblPrice");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity");
            this.Property(t => t.dblUnit).HasColumnName("dblUnit");
            this.Property(t => t.intBundleItemId).HasColumnName("intBundleItemId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intItemBundleId).HasColumnName("intItemBundleId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");

            this.HasOptional(p => p.BundleItem)
                .WithMany(p => p.tblICItemBundles)
                .HasForeignKey(p => p.intBundleItemId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemBundles)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }
}
