using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMLineOfBusinessMap: EntityTypeConfiguration<tblSMLineOfBusiness>
    {
        public tblSMLineOfBusinessMap()
        {
            // Primary Key
            this.HasKey(t => t.intLineOfBusinessId);

            // Table & Column Mappings
            this.ToTable("tblSMLineOfBusiness");
            this.Property(t => t.intLineOfBusinessId).HasColumnName("intLineOfBusinessId");            
            this.Property(t => t.strLineOfBusiness).HasColumnName("strLineOfBusiness");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.ysnVisibleOnWeb).HasColumnName("ysnVisibleOnWeb");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strSICCode).HasColumnName("strSICCode");
            this.Property(t => t.intSegmentCodeId).HasColumnName("intSegmentCodeId");
        }
    }
}
