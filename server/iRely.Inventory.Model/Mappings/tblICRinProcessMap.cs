using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICRinProcessMap : EntityTypeConfiguration<tblICRinProcess>
    {
        public tblICRinProcessMap()
        {
            // Primary Key
            this.HasKey(t => t.intRinProcessId);

            // Table & Column Mappings
            this.ToTable("tblICRinProcess");
            this.Property(t => t.intRinProcessId).HasColumnName("intRinProcessId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strRinProcessCode).HasColumnName("strRinProcessCode");
        }
    }
}
