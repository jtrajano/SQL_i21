using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemPOSCategoryMap : EntityTypeConfiguration<tblICItemPOSCategory>
    {
        public tblICItemPOSCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPOSCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICItemPOSCategory");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intItemPOSCategoryId).HasColumnName("intItemPOSCategoryId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }

    public class tblICItemPOSSLAMap : EntityTypeConfiguration<tblICItemPOSSLA>
    {
        public tblICItemPOSSLAMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemPOSSLAId);

            // Table & Column Mappings
            this.ToTable("tblICItemPOSSLA");
            this.Property(t => t.dblContractPrice).HasColumnName("dblContractPrice");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemPOSSLAId).HasColumnName("intItemPOSSLAId");
            this.Property(t => t.strSLAContract).HasColumnName("strSLAContract");
            this.Property(t => t.ysnServiceWarranty).HasColumnName("ysnServiceWarranty");
        }
    }
}
