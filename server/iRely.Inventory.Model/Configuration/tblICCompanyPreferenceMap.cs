using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCompanyPreferenceMap : EntityTypeConfiguration<tblICCompanyPreference>
    {
        public tblICCompanyPreferenceMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyPreferenceId);

            // Table & Column Mappings
            this.ToTable("tblICCompanyPreference");
            this.Property(t => t.intCompanyPreferenceId).HasColumnName("intCompanyPreferenceId");
            this.Property(t => t.intInheritSetup).HasColumnName("intInheritSetup");
            this.Property(t => t.intSort).HasColumnName("intSort");
        }
    }
}
