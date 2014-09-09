using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryStoreMap : EntityTypeConfiguration<tblICCategoryStore>
    {
        public tblICCategoryStoreMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryStoreId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryStore");
            this.Property(t => t.dblCostInventoryBOM).HasColumnName("dblCostInventoryBOM");
            this.Property(t => t.dblHighGrossMarginAlert).HasColumnName("dblHighGrossMarginAlert");
            this.Property(t => t.dblLowGrossMarginAlert).HasColumnName("dblLowGrossMarginAlert");
            this.Property(t => t.dblTargetGrossProfit).HasColumnName("dblTargetGrossProfit");
            this.Property(t => t.dblTargetInventoryCost).HasColumnName("dblTargetInventoryCost");
            this.Property(t => t.dtmLastInventoryLevelEntry).HasColumnName("dtmLastInventoryLevelEntry");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intCategoryStoreId).HasColumnName("intCategoryStoreId");
            this.Property(t => t.intNucleusGroupId).HasColumnName("intNucleusGroupId");
            this.Property(t => t.intRegisterDepartmentId).HasColumnName("intRegisterDepartmentId");
            this.Property(t => t.intStoreId).HasColumnName("intStoreId");
            this.Property(t => t.ysnBlueLaw1).HasColumnName("ysnBlueLaw1");
            this.Property(t => t.ysnBlueLaw2).HasColumnName("ysnBlueLaw2");
            this.Property(t => t.ysnUpdatePrices).HasColumnName("ysnUpdatePrices");
            this.Property(t => t.ysnUseTaxFlag1).HasColumnName("ysnUseTaxFlag1");
            this.Property(t => t.ysnUseTaxFlag2).HasColumnName("ysnUseTaxFlag2");
            this.Property(t => t.ysnUseTaxFlag3).HasColumnName("ysnUseTaxFlag3");
            this.Property(t => t.ysnUseTaxFlag4).HasColumnName("ysnUseTaxFlag4");
        }
    }
}
