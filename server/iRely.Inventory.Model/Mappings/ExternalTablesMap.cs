using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationMap: EntityTypeConfiguration<tblSMCompanyLocation>
    {
        public tblSMCompanyLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyLocationId);

            // Table & Column Mappings
            this.ToTable("tblSMCompanyLocation");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
        }
    }

    public class tblGLAccountMap : EntityTypeConfiguration<tblGLAccount>
    {
        public tblGLAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intAccountId);

            // Table & Column Mappings
            this.ToTable("tblGLAccount");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.strAccountId).HasColumnName("strAccountId");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
        }
    }
}
