using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCatalogMap : EntityTypeConfiguration<tblICCatalog>
    {
        public tblICCatalogMap()
        {
            // Primary Key
            this.HasKey(t => t.intCatalogId);

            // Table & Column Mappings
            this.ToTable("tblICCatalog");
            this.Property(t => t.intCatalogId).HasColumnName("intCatalogId");
            this.Property(t => t.intParentCatalogId).HasColumnName("intParentCatalogId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strCatalogName).HasColumnName("strCatalogName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnLeaf).HasColumnName("ysnLeaf");
        }
    }
}
