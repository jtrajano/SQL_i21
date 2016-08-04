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
            this.Property(t => t.strLotCondition).HasColumnName("strLotCondition");
            this.Property(t => t.strReceiptType).HasColumnName("strReceiptType");
            this.Property(t => t.intReceiptSourceType).HasColumnName("intReceiptSourceType");
            this.Property(t => t.intShipmentOrderType).HasColumnName("intShipmentOrderType");
            this.Property(t => t.intShipmentSourceType).HasColumnName("intShipmentSourceType");
        }
    }
}
