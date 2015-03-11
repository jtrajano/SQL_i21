using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryLocationMap : EntityTypeConfiguration<tblICCategoryLocation>
    {
        public tblICCategoryLocationMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryLocationId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryLocation");
            this.Property(t => t.intCategoryLocationId).HasColumnName("intCategoryLocationId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intRegisterDepartmentId).HasColumnName("intRegisterDepartmentId");
            this.Property(t => t.ysnUpdatePrices).HasColumnName("ysnUpdatePrices");
            this.Property(t => t.ysnUseTaxFlag1).HasColumnName("ysnUseTaxFlag1");
            this.Property(t => t.ysnUseTaxFlag2).HasColumnName("ysnUseTaxFlag2");
            this.Property(t => t.ysnUseTaxFlag3).HasColumnName("ysnUseTaxFlag3");
            this.Property(t => t.ysnUseTaxFlag4).HasColumnName("ysnUseTaxFlag4");
            this.Property(t => t.ysnBlueLaw1).HasColumnName("ysnBlueLaw1");
            this.Property(t => t.ysnBlueLaw2).HasColumnName("ysnBlueLaw2");
            this.Property(t => t.intNucleusGroupId).HasColumnName("intNucleusGroupId");
            this.Property(t => t.dblTargetGrossProfit).HasColumnName("dblTargetGrossProfit").HasPrecision(18, 6);
            this.Property(t => t.dblTargetInventoryCost).HasColumnName("dblTargetInventoryCost").HasPrecision(18, 6);
            this.Property(t => t.dblCostInventoryBOM).HasColumnName("dblCostInventoryBOM").HasPrecision(18, 6);
            this.Property(t => t.dblLowGrossMarginAlert).HasColumnName("dblLowGrossMarginAlert").HasPrecision(18, 6);
            this.Property(t => t.dblHighGrossMarginAlert).HasColumnName("dblHighGrossMarginAlert").HasPrecision(18, 6);
            this.Property(t => t.dtmLastInventoryLevelEntry).HasColumnName("dtmLastInventoryLevelEntry");
            this.Property(t => t.ysnNonRetailUseDepartment).HasColumnName("ysnNonRetailUseDepartment");
            this.Property(t => t.ysnReportNetGross).HasColumnName("ysnReportNetGross");
            this.Property(t => t.ysnDepartmentForPumps).HasColumnName("ysnDepartmentForPumps");
            this.Property(t => t.intConvertPaidOutId).HasColumnName("intConvertPaidOutId");
            this.Property(t => t.ysnDeleteFromRegister).HasColumnName("ysnDeleteFromRegister");
            this.Property(t => t.ysnDeptKeyTaxed).HasColumnName("ysnDeptKeyTaxed");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.ysnFoodStampable).HasColumnName("ysnFoodStampable");
            this.Property(t => t.ysnReturnable).HasColumnName("ysnReturnable");
            this.Property(t => t.ysnSaleable).HasColumnName("ysnSaleable");
            this.Property(t => t.ysnPrePriced).HasColumnName("ysnPrePriced");
            this.Property(t => t.ysnIdRequiredLiquor).HasColumnName("ysnIdRequiredLiquor");
            this.Property(t => t.ysnIdRequiredCigarette).HasColumnName("ysnIdRequiredCigarette");
            this.Property(t => t.intMinimumAge).HasColumnName("intMinimumAge");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblSMCompanyLocation)
                .WithMany(p => p.tblICCategoryLocations)
                .HasForeignKey(p => p.intLocationId);
        }
    }
}
