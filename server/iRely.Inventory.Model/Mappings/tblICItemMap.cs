using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemMap : EntityTypeConfiguration<tblICItem>
    {
        public tblICItemMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemId);

            // Table & Column Mappings
            this.ToTable("tblICItem");
            this.Property(t => t.dblCaseQty).HasColumnName("dblCaseQty");
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull");
            this.Property(t => t.dblDenaturantPercent).HasColumnName("dblDenaturantPercent");
            this.Property(t => t.dblDepth).HasColumnName("dblDepth");
            this.Property(t => t.dblGAShrinkFactor).HasColumnName("dblGAShrinkFactor");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight");
            this.Property(t => t.dblMixOrder).HasColumnName("dblMixOrder");
            this.Property(t => t.dblStandardPalletRatio).HasColumnName("dblStandardPalletRatio");
            this.Property(t => t.dblTaxExempt).HasColumnName("dblTaxExempt");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight");
            this.Property(t => t.dblWidth).HasColumnName("dblWidth");
            this.Property(t => t.dtmDateShip).HasColumnName("dtmDateShip");
            this.Property(t => t.intAGCategory).HasColumnName("intAGCategory");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intClassVarietyId).HasColumnName("intClassVarietyId");
            this.Property(t => t.intCommodityHierarchyId).HasColumnName("intCommodityHierarchyId");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.intIngredientTag).HasColumnName("intIngredientTag");
            this.Property(t => t.intInnerUnits).HasColumnName("intInnerUnits");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intMaterialPackTypeId).HasColumnName("intMaterialPackTypeId");
            this.Property(t => t.intMedicationTag).HasColumnName("intMedicationTag");
            this.Property(t => t.intNMFCId).HasColumnName("intNMFCId");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intPhysicalItem).HasColumnName("intPhysicalItem");
            this.Property(t => t.intProductLineId).HasColumnName("intProductLineId");
            this.Property(t => t.intProductTypeId).HasColumnName("intProductTypeId");
            this.Property(t => t.intReceiveLife).HasColumnName("intReceiveLife");
            this.Property(t => t.intRecipeId).HasColumnName("intRecipeId");
            this.Property(t => t.intRegionId).HasColumnName("intRegionId");
            this.Property(t => t.intRINFuelTypeId).HasColumnName("intRINFuelTypeId");
            this.Property(t => t.intSeasonId).HasColumnName("intSeasonId");
            this.Property(t => t.intTaxClassId).HasColumnName("intTaxClassId");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.strBarcodePrint).HasColumnName("strBarcodePrint");
            this.Property(t => t.strCountCode).HasColumnName("strCountCode");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strEPANumber).HasColumnName("strEPANumber");
            this.Property(t => t.strFuelInspectFee).HasColumnName("strFuelInspectFee");
            this.Property(t => t.strGTIN).HasColumnName("strGTIN");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strKeywords).HasColumnName("strKeywords");
            this.Property(t => t.strLeadTime).HasColumnName("strLeadTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strMarketValuation).HasColumnName("strMarketValuation");
            this.Property(t => t.strMask1).HasColumnName("strMask1");
            this.Property(t => t.strMask2).HasColumnName("strMask2");
            this.Property(t => t.strMask3).HasColumnName("strMask3");
            this.Property(t => t.strMaterialSizeCode).HasColumnName("strMaterialSizeCode");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strNACSCategory).HasColumnName("strNACSCategory");
            this.Property(t => t.strRINRequired).HasColumnName("strRINRequired");
            this.Property(t => t.strRotationType).HasColumnName("strRotationType");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strVolumeRebateGroup).HasColumnName("strVolumeRebateGroup");
            this.Property(t => t.strWICCode).HasColumnName("strWICCode");
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.ysnCommisionable).HasColumnName("ysnCommisionable");
            this.Property(t => t.ysnDropShip).HasColumnName("ysnDropShip");
            this.Property(t => t.ysnDyedFuel).HasColumnName("ysnDyedFuel");
            this.Property(t => t.ysnExportEDI).HasColumnName("ysnExportEDI");
            this.Property(t => t.ysnExtendPickTicket).HasColumnName("ysnExtendPickTicket");
            this.Property(t => t.ysnHandAddIngredient).HasColumnName("ysnHandAddIngredient");
            this.Property(t => t.ysnHazardMaterial).HasColumnName("ysnHazardMaterial");
            this.Property(t => t.ysnInboundTax).HasColumnName("ysnInboundTax");
            this.Property(t => t.ysnLandedCost).HasColumnName("ysnLandedCost");
            this.Property(t => t.ysnLoadTracking).HasColumnName("ysnLoadTracking");
            this.Property(t => t.ysnMaterialFee).HasColumnName("ysnMaterialFee");
            this.Property(t => t.ysnMSDSRequired).HasColumnName("ysnMSDSRequired");
            this.Property(t => t.ysnOutboundTax).HasColumnName("ysnOutboundTax");
            this.Property(t => t.ysnReceiptCommentRequired).HasColumnName("ysnReceiptCommentRequired");
            this.Property(t => t.ysnRequireCustomerApproval).HasColumnName("ysnRequireCustomerApproval");
            this.Property(t => t.ysnRestrictedChemical).HasColumnName("ysnRestrictedChemical");
            this.Property(t => t.ysnSanitationRequired).HasColumnName("ysnSanitationRequired");
            this.Property(t => t.ysnSpecialCommission).HasColumnName("ysnSpecialCommission");
            this.Property(t => t.ysnStockedItem).HasColumnName("ysnStockedItem");
            this.Property(t => t.ysnStrictFIFO).HasColumnName("ysnStrictFIFO");
            this.Property(t => t.ysnTankRequired).HasColumnName("ysnTankRequired");
            this.Property(t => t.ysnTaxable).HasColumnName("ysnTaxable");
            this.Property(t => t.ysnTonnageTax).HasColumnName("ysnTonnageTax");

            this.HasOptional(p => p.tblICBrand)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intBrandId);
            this.HasOptional(p => p.tblICManufacturer)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intManufacturerId);

            this.HasMany(p => p.tblICItemUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemLocations)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            
            this.HasMany(p => p.tblICItemPOSCategories)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPOSSLAs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemManufacturingUOMs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            
            this.HasMany(p => p.tblICItemCertifications)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemContracts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemCustomerXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemVendorXrefs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemUPCs)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);

            this.HasMany(p => p.tblICItemAssemblies)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemBundles)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemKits)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);

            this.HasMany(p => p.tblICItemPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemPricingLevels)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemSpecialPricings)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemStocks)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemAccounts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemNotes)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);

            this.HasMany(p => p.tblICItemFactories)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
            this.HasMany(p => p.tblICItemOwners)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
        }
    }

    public class vyuICGetItemStockMap : EntityTypeConfiguration<vyuICGetItemStock>
    {
        public vyuICGetItemStockMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStock");
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost");
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder");
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted");
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand");
            this.Property(t => t.intAllowNegativeInventory).HasColumnName("intAllowNegativeInventory");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.dblMinOrder).HasColumnName("dblMinOrder");
            this.Property(t => t.dblReorderPoint).HasColumnName("dblReorderPoint");
            this.Property(t => t.strAllowNegativeInventory).HasColumnName("strAllowNegativeInventory");
            this.Property(t => t.strCostingMethod).HasColumnName("strCostingMethod");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strIssueUOM).HasColumnName("strIssueUOM");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.strReceiveUOM).HasColumnName("strReceiveUOM");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");

            this.HasMany(p => p.tblICItemAccounts)
                .WithRequired(p => p.vyuICGetItemStock)
                .HasForeignKey(p => p.intKey);
            this.HasMany(p => p.tblICItemPricings)
                .WithRequired(p => p.vyuICGetItemStock)
                .HasForeignKey(p => p.intKey);
        }
    }

    public class vyuICGetItemPricingMap : EntityTypeConfiguration<vyuICGetItemPricing>
    {
        public vyuICGetItemPricingMap()
        {
            // Primary Key
            this.HasKey(p => p.intPricingKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemPricing");
            this.Property(t => t.dblAmountPercent).HasColumnName("dblAmountPercent");
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost");
            this.Property(t => t.dblLargeVolumePrice).HasColumnName("dblLargeVolumePrice");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost");
            this.Property(t => t.dblMovingAverageCost).HasColumnName("dblMovingAverageCost");
            this.Property(t => t.dblMSRPPrice).HasColumnName("dblMSRPPrice");
            this.Property(t => t.dblRetailPrice).HasColumnName("dblRetailPrice");
            this.Property(t => t.dblSalePrice).HasColumnName("dblSalePrice");
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost");
            this.Property(t => t.dblWholesalePrice).HasColumnName("dblWholesalePrice");
            this.Property(t => t.dtmBeginDate).HasColumnName("dtmBeginDate");
            this.Property(t => t.dtmEndDate).HasColumnName("dtmEndDate");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemPricingId).HasColumnName("intItemPricingId");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.intPricingKey).HasColumnName("intPricingKey");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
        }
    }

    public class vyuICGetItemAccountMap : EntityTypeConfiguration<vyuICGetItemAccount>
    {
        public vyuICGetItemAccountMap()
        {
            // Primary Key
            this.HasKey(p => p.intAccountKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemAccount");
            this.Property(t => t.intAccountGroupId).HasColumnName("intAccountGroupId");
            this.Property(t => t.intAccountId).HasColumnName("intAccountId");
            this.Property(t => t.intItemAccountId).HasColumnName("intItemAccountId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(p => p.intAccountKey).HasColumnName("intAccountKey");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.strAccountCategory).HasColumnName("strAccountCategory");
            this.Property(t => t.strAccountGroup).HasColumnName("strAccountGroup");
            this.Property(t => t.strAccountId).HasColumnName("strAccountId");
            this.Property(t => t.strAccountType).HasColumnName("strAccountType");
        }
    }
}
