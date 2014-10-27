using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCommodityAttributeMap : EntityTypeConfiguration<tblICCommodityAttribute>
    {
        public tblICCommodityAttributeMap()
        {
            // Primary Key
            this.HasKey(t => t.intCommodityAttributeId);

            // Table & Column Mappings
            this.ToTable("tblICCommodityAttribute");
            this.Property(t => t.intCommodityAttributeId).HasColumnName("intCommodityAttributeId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strType).HasColumnName("strType");
        }
    }
}
