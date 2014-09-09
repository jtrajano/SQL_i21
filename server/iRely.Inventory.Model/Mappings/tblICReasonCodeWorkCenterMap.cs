using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICReasonCodeWorkCenterMap : EntityTypeConfiguration<tblICReasonCodeWorkCenter>
    {
        public tblICReasonCodeWorkCenterMap()
        {
            // Primary Key
            this.HasKey(t => t.intReasonCodeWorkCenterId);

            // Table & Column Mappings
            this.ToTable("tblICReasonCodeWorkCenter");
            this.Property(t => t.intReasonCodeId).HasColumnName("intReasonCodeId");
            this.Property(t => t.intReasonCodeWorkCenterId).HasColumnName("intReasonCodeWorkCenterId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strWorkCenterId).HasColumnName("strWorkCenterId");
        }
    }
}
