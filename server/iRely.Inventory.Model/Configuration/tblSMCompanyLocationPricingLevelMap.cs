using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblSMCompanyLocationPricingLevelMap : EntityTypeConfiguration<tblSMCompanyLocationPricingLevel>
    {
        public tblSMCompanyLocationPricingLevelMap()
        {
            // Primary Key
            this.HasKey(t => t.intCompanyLocationPricingLevelId);

            // Table & Column Mappings
            this.ToTable("tblSMCompanyLocationPricingLevel");
            this.Property(t => t.intCompanyLocationPricingLevelId).HasColumnName("intCompanyLocationPricingLevelId");
            this.Property(t => t.intCompanyLocationId).HasColumnName("intCompanyLocationId");
            this.Property(t => t.strPricingLevelName).HasColumnName("strPricingLevelName");
        }
    }
}
