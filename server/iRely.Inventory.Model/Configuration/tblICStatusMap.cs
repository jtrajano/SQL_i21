using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICStatusMap: EntityTypeConfiguration<tblICStatus>
    {
        public tblICStatusMap()
        {
            // Primary Key
            this.HasKey(t => t.intStatusId);

            // Table & Column Mappings
            this.ToTable("tblICStatus");
            this.Property(t => t.intStatusId).HasColumnName("intStatusId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
        }
    }
}
