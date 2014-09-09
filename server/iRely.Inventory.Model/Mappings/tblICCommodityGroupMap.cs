using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityGroupMap : EntityTypeConfiguration<tblICCommodityGroup>
    {
        public tblICCommodityGroupMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityGroupId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityGroup");
            this.Property(t => t.intCommodityGroupId).HasColumnName("intCommodityGroupId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intParentGroupId).HasColumnName("intParentGroupId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }
}
