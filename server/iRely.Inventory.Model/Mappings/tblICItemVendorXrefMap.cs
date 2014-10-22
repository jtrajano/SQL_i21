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
            this.Property(t => t.dblConversionFactor).HasColumnName("dblConversionFactor");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemVendorXrefId).HasColumnName("intItemVendorXrefId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strProductDescription).HasColumnName("strProductDescription");
            this.Property(t => t.strStoreName).HasColumnName("strStoreName");
            this.Property(t => t.strVendorProduct).HasColumnName("strVendorProduct");

            this.HasOptional(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intLocationId);
            this.HasOptional(p => p.vyuAPVendor)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intVendorId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICItemVendorXrefs)
                .HasForeignKey(p => p.intUnitMeasureId);
                
        }
    }
}
