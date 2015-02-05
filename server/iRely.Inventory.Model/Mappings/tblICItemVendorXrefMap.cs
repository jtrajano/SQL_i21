using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemVendorXrefMap : EntityTypeConfiguration<tblICItemVendorXref>
    {
        public tblICItemVendorXrefMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemVendorXrefId);

            // Table & Column Mappings
            this.ToTable("tblICItemVendorXref");
            this.Property(t => t.intItemVendorXrefId).HasColumnName("intItemVendorXrefId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strVendorProduct).HasColumnName("strVendorProduct");
            this.Property(t => t.strProductDescription).HasColumnName("strProductDescription");
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intItemLocationId);
            this.HasOptional(p => p.vyuAPVendor)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intVendorId);
            this.HasOptional(p => p.tblICItemUOM)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intItemUnitMeasureId);
                
        }
    }
}
