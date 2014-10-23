using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCountGroupMap : EntityTypeConfiguration<tblICCountGroup>
    {
        public tblICCountGroupMap()
        {
            // Primary Key
            this.HasKey(t => t.intCountGroupId);

            // Table & Column Mappings
            this.ToTable("tblICCountGroup");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strCountGroup).HasColumnName("strCountGroup");
        }
    }
}
