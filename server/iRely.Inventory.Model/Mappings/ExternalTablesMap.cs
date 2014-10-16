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
}
