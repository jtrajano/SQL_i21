using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICLotStatusMap : EntityTypeConfiguration<tblICLotStatus>
    {
        public tblICLotStatusMap()
        {
            // Primary Key
            this.HasKey(t => t.intLotStatusId);

            // Table & Column Mappings
            this.ToTable("tblICLotStatus");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strPrimaryStatus).HasColumnName("strPrimaryStatus");
            this.Property(t => t.strSecondaryStatus).HasColumnName("strSecondaryStatus");
        }
    }
}
