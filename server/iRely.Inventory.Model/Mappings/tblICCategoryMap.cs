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
            this.Property(t => t.intLineOfBusinessId).HasColumnName("intLineOfBusinessId");
            this.Property(t => t.intCatalogGroupId).HasColumnName("intCatalogGroupId");
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

            this.HasOptional(p => p.tblICCatalog)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intCatalogGroupId);
            this.HasOptional(p => p.tblICUnitMeasure)
                .WithMany(p => p.tblICCategories)
                .HasForeignKey(p => p.intUOMId);
                
        }
    }
}
