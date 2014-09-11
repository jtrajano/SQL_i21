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
            this.Property(t => t.dblBOMItemLowerTolerance).HasColumnName("dblBOMItemLowerTolerance");
            this.Property(t => t.dblBOMItemShrinkage).HasColumnName("dblBOMItemShrinkage");
            this.Property(t => t.dblBOMItemUpperTolerance).HasColumnName("dblBOMItemUpperTolerance");
            this.Property(t => t.dblfeTime).HasColumnName("dblfeTime");
            this.Property(t => t.dblLaborCost).HasColumnName("dblLaborCost");
            this.Property(t => t.dblOverHead).HasColumnName("dblOverHead");
            this.Property(t => t.dblPercentage).HasColumnName("dblPercentage");
            this.Property(t => t.dblStandardQty).HasColumnName("dblStandardQty");
            this.Property(t => t.imgFGImage).HasColumnName("imgFGImage");
            this.Property(t => t.imgReceiptImage).HasColumnName("imgReceiptImage");
            this.Property(t => t.imgShipImage).HasColumnName("imgShipImage");
            this.Property(t => t.imgWIPImage).HasColumnName("imgWIPImage");
            this.Property(t => t.intCatalogGroupId).HasColumnName("intCatalogGroupId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.intConvertPaidOutId).HasColumnName("intConvertPaidOutId");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.intFreightItemId).HasColumnName("intFreightItemId");
            this.Property(t => t.intMaterialItemId).HasColumnName("intMaterialItemId");
            this.Property(t => t.intMinimumAge).HasColumnName("intMinimumAge");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.intUOMId).HasColumnName("intUOMId");
            this.Property(t => t.strBOMItemType).HasColumnName("strBOMItemType");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strConsumptionMethod).HasColumnName("strConsumptionMethod");
            this.Property(t => t.strCostDistributionMethod).HasColumnName("strCostDistributionMethod");
            this.Property(t => t.strCostingMethod).HasColumnName("strCostingMethod");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strERPItemClass).HasColumnName("strERPItemClass");
            this.Property(t => t.strGLDivisionNumber).HasColumnName("strGLDivisionNumber");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.strLineBusiness).HasColumnName("strLineBusiness");
            this.Property(t => t.strMaterialFee).HasColumnName("strMaterialFee");
            this.Property(t => t.strShortName).HasColumnName("strShortName");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.ysnDeleteRegister).HasColumnName("ysnDeleteRegister");
            this.Property(t => t.ysnDepartmentKeyTaxed).HasColumnName("ysnDepartmentKeyTaxed");
            this.Property(t => t.ysnDepartmentPumps).HasColumnName("ysnDepartmentPumps");
            this.Property(t => t.ysnFoodStampable).HasColumnName("ysnFoodStampable");
            this.Property(t => t.ysnIdRequiredCigarette).HasColumnName("ysnIdRequiredCigarette");
            this.Property(t => t.ysnIdRequiredLiquor).HasColumnName("ysnIdRequiredLiquor");
            this.Property(t => t.ysnNonRetailUseDepartment).HasColumnName("ysnNonRetailUseDepartment");
            this.Property(t => t.ysnOutputItemMandatory).HasColumnName("ysnOutputItemMandatory");
            this.Property(t => t.ysnPrepriced).HasColumnName("ysnPrepriced");
            this.Property(t => t.ysnReportNetGross).HasColumnName("ysnReportNetGross");
            this.Property(t => t.ysnReturnable).HasColumnName("ysnReturnable");
            this.Property(t => t.ysnSaleable).HasColumnName("ysnSaleable");
            this.Property(t => t.ysnSalesAnalysisByTon).HasColumnName("ysnSalesAnalysisByTon");
            this.Property(t => t.ysnScaled).HasColumnName("ysnScaled");
            this.Property(t => t.ysnSellable).HasColumnName("ysnSellable");
            this.Property(t => t.ysnYieldAdjustment).HasColumnName("ysnYieldAdjustment");

            this.HasMany(p => p.tblICCategoryAccounts)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryStores)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);
            this.HasMany(p => p.tblICCategoryVendors)
                .WithRequired(p => p.tblICCategory)
                .HasForeignKey(p => p.intCategoryId);

            this.HasOptional(p => p.tblICCatalog)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intCatalogGroupId);
            this.HasOptional(p => p.tblICClass)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intCatalogGroupId);
            this.HasOptional(p => p.tblICFamily)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intCatalogGroupId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intCatalogGroupId);
                
        }
    }
}
