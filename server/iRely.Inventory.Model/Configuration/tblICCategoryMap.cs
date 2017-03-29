using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICCategoryMap : EntityTypeConfiguration<tblICCategory>
    {
        public tblICCategoryMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryId);

            // Table & Column Mappings
            this.ToTable("tblICCategory");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strInventoryType).HasColumnName("strInventoryType");
            this.Property(t => t.intLineOfBusinessId).HasColumnName("intLineOfBusinessId");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.dblStandardQty).HasColumnName("dblStandardQty").HasPrecision(18, 6);
            this.Property(t => t.intUOMId).HasColumnName("intUOMId");
            this.Property(t => t.strGLDivisionNumber).HasColumnName("strGLDivisionNumber");
            this.Property(t => t.ysnSalesAnalysisByTon).HasColumnName("ysnSalesAnalysisByTon");
            this.Property(t => t.strMaterialFee).HasColumnName("strMaterialFee");
            this.Property(t => t.intMaterialItemId).HasColumnName("intMaterialItemId");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.intFreightItemId).HasColumnName("intFreightItemId");
            this.Property(t => t.strERPItemClass).HasColumnName("strERPItemClass");
            this.Property(t => t.dblLifeTime).HasColumnName("dblLifeTime").HasPrecision(18, 6);
            this.Property(t => t.dblBOMItemShrinkage).HasColumnName("dblBOMItemShrinkage").HasPrecision(18, 6);
            this.Property(t => t.dblBOMItemUpperTolerance).HasColumnName("dblBOMItemUpperTolerance").HasPrecision(18, 6);
            this.Property(t => t.dblBOMItemLowerTolerance).HasColumnName("dblBOMItemLowerTolerance").HasPrecision(18, 6);
            this.Property(t => t.ysnScaled).HasColumnName("ysnScaled");
            this.Property(t => t.ysnOutputItemMandatory).HasColumnName("ysnOutputItemMandatory");
            this.Property(t => t.strConsumptionMethod).HasColumnName("strConsumptionMethod");
            this.Property(t => t.strBOMItemType).HasColumnName("strBOMItemType");
            this.Property(t => t.strShortName).HasColumnName("strShortName");
            this.Property(t => t.imgReceiptImage).HasColumnName("imgReceiptImage");
            this.Property(t => t.imgWIPImage).HasColumnName("imgWIPImage");
            this.Property(t => t.imgFGImage).HasColumnName("imgFGImage");
            this.Property(t => t.imgShipImage).HasColumnName("imgShipImage");
            this.Property(t => t.dblLaborCost).HasColumnName("dblLaborCost").HasPrecision(18, 6);
            this.Property(t => t.dblOverHead).HasColumnName("dblOverHead").HasPrecision(18, 6);
            this.Property(t => t.dblPercentage).HasColumnName("dblPercentage").HasPrecision(18, 6);
            this.Property(t => t.strCostDistributionMethod).HasColumnName("strCostDistributionMethod");
            this.Property(t => t.ysnSellable).HasColumnName("ysnSellable");
            this.Property(t => t.ysnYieldAdjustment).HasColumnName("ysnYieldAdjustment");
            this.Property(t => t.ysnWarehouseTracked).HasColumnName("ysnWarehouseTracked");

            this.HasMany(p => p.tblICCategoryTaxes)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryAccounts)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryLocations)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryVendors)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryUOMs)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);

            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intUOMId);

            this.HasOptional(p => p.tblSMLineOfBusiness)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intLineOfBusinessId);
                
        }
    }

    public class tblICCategoryAccountMap : EntityTypeConfiguration<tblICCategoryAccount>
    {
        public tblICCategoryAccountMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryAccountId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryAccount");
            this.Property(t => t.intCategoryAccountId).HasColumnName("intCategoryAccountId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblGLAccount)
                .WithMany(p => p.tblICCategoryAccounts)
                .HasForeignKey(p => p.intAccountId);
            this.HasOptional(p => p.tblGLAccountCategory)
                .WithMany(p => p.tblICCategoryAccounts)
                .HasForeignKey(p => p.intAccountCategoryId);
        }
    }

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

    public class tblICCategoryVendorMap : EntityTypeConfiguration<tblICCategoryVendor>
    {
        public tblICCategoryVendorMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryVendorId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryVendor");
            this.Property(t => t.intCategoryVendorId).HasColumnName("intCategoryVendorId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intCategoryLocationId).HasColumnName("intCategoryLocationId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strVendorDepartment).HasColumnName("strVendorDepartment");
            this.Property(t => t.ysnAddOrderingUPC).HasColumnName("ysnAddOrderingUPC");
            this.Property(t => t.ysnUpdateExistingRecords).HasColumnName("ysnUpdateExistingRecords");
            this.Property(t => t.ysnAddNewRecords).HasColumnName("ysnAddNewRecords");
            this.Property(t => t.ysnUpdatePrice).HasColumnName("ysnUpdatePrice");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intSellClassId).HasColumnName("intSellClassId");
            this.Property(t => t.intOrderClassId).HasColumnName("intOrderClassId");
            this.Property(t => t.strComments).HasColumnName("strComments");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICCategoryLocation)
                .WithMany(p => p.tblICCategoryVendors)
                .HasForeignKey(p => p.intCategoryLocationId);
            this.HasOptional(p => p.Family)
                .WithMany(p => p.tblICCategoryVendorFamily)
                .HasForeignKey(p => p.intFamilyId);
            this.HasOptional(p => p.OrderClass)
                .WithMany(p => p.tblICCategoryVendorOrderClasses)
                .HasForeignKey(p => p.intOrderClassId);
            this.HasOptional(p => p.SellClass)
                .WithMany(p => p.tblICCategoryVendorSellClasses)
                .HasForeignKey(p => p.intSellClassId);
            this.HasRequired(p => p.vyuAPVendor)
                .WithMany(p => p.tblICCategoryVendors)
                .HasForeignKey(p => p.intVendorId);
        }
    }

    public class tblICCategoryUOMMap : EntityTypeConfiguration<tblICCategoryUOM>
    {
        public tblICCategoryUOMMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryUOMId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryUOM");
            this.Property(t => t.intCategoryUOMId).HasColumnName("intCategoryUOMId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.ysnDefault).HasColumnName("ysnDefault");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasRequired(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCategoryUOMs)
                .HasForeignKey(p => p.intUnitMeasureId);
        }
    }

    public class tblICCategoryTaxMap : EntityTypeConfiguration<tblICCategoryTax>
    {
        public tblICCategoryTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryTaxId);

            // Table & Column Mappings
            this.ToTable("tblICCategoryTax");
            this.Property(t => t.intCategoryTaxId).HasColumnName("intCategoryTaxId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");

            this.HasOptional(p => p.vyuICGetCategoryTax)
                .WithRequired(p => p.tblICCategoryTax);
        }
    }

    public class vyuICGetCategoryTaxMap : EntityTypeConfiguration<vyuICGetCategoryTax>
    {
        public vyuICGetCategoryTaxMap()
        {
            // Primary Key
            this.HasKey(t => t.intCategoryTaxId);

            // Table & Column Mappings
            this.ToTable("vyuICGetCategoryTax");
            this.Property(t => t.intCategoryTaxId).HasColumnName("intCategoryTaxId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strTaxClass).HasColumnName("strTaxClass");
            this.Property(t => t.ysnActive).HasColumnName("ysnActive");
        }
    }
}
