using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICBrandMap: EntityTypeConfiguration<tblICBrand>
    {
        public tblICBrandMap()
        {
            // Primary Key
            this.HasKey(t => t.intBrandId);

            // Table & Column Mappings
            this.ToTable("tblICBrand");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strBrandCode).HasColumnName("strBrandCode");
            this.Property(t => t.strBrandName).HasColumnName("strBrandName");

            this.HasOptional(p => p.tblICManufacturer)
                .WithMany(p => p.tblICBrands)
                .HasForeignKey(p => p.intManufacturerId);
        }
    }
}
