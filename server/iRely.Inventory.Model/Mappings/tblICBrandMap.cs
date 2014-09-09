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
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strBrand).HasColumnName("strBrand");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }
}
