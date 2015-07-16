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
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.ysnRequireCustomerApproval).HasColumnName("ysnRequireCustomerApproval");
            this.Property(t => t.intRecipeId).HasColumnName("intRecipeId");
            this.Property(t => t.ysnSanitationRequired).HasColumnName("ysnSanitationRequired");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.intReceiveLife).HasColumnName("intReceiveLife");
            this.Property(t => t.strGTIN).HasColumnName("strGTIN");
            this.Property(t => t.strRotationType).HasColumnName("strRotationType");
            this.Property(t => t.intNMFCId).HasColumnName("intNMFCId");
            this.Property(t => t.ysnStrictFIFO).HasColumnName("ysnStrictFIFO");
            this.Property(t => t.intDimensionUOMId).HasColumnName("intDimensionUOMId");
            this.Property(t => t.dblHeight).HasColumnName("dblHeight").HasPrecision(18, 6);
            this.Property(t => t.dblWidth).HasColumnName("dblWidth").HasPrecision(18, 6);
            this.Property(t => t.dblDepth).HasColumnName("dblDepth").HasPrecision(18, 6);
            this.Property(t => t.intWeightUOMId).HasColumnName("intWeightUOMId");
            this.Property(t => t.dblWeight).HasColumnName("dblWeight").HasPrecision(18, 6);
            this.Property(t => t.intMaterialPackTypeId).HasColumnName("intMaterialPackTypeId");
            this.Property(t => t.strMaterialSizeCode).HasColumnName("strMaterialSizeCode");
            this.Property(t => t.intInnerUnits).HasColumnName("intInnerUnits");
            this.Property(t => t.intLayerPerPallet).HasColumnName("intLayerPerPallet");
            this.Property(t => t.intUnitPerLayer).HasColumnName("intUnitPerLayer");
            this.Property(t => t.dblStandardPalletRatio).HasColumnName("dblStandardPalletRatio").HasPrecision(18, 6);
            this.Property(t => t.strMask1).HasColumnName("strMask1");
            this.Property(t => t.strMask2).HasColumnName("strMask2");
            this.Property(t => t.strMask3).HasColumnName("strMask3");
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intFuelTaxClassId).HasColumnName("intFuelTaxClassId");
            this.Property(t => t.intSalesTaxGroupId).HasColumnName("intSalesTaxGroupId");
            this.Property(t => t.intPurchaseTaxGroupId).HasColumnName("intPurchaseTaxGroupId");
            this.Property(t => t.ysnStockedItem).HasColumnName("ysnStockedItem");
            this.Property(t => t.ysnDyedFuel).HasColumnName("ysnDyedFuel");
            this.Property(t => t.strBarcodePrint).HasColumnName("strBarcodePrint");
            this.Property(t => t.ysnMSDSRequired).HasColumnName("ysnMSDSRequired");
            this.Property(t => t.strEPANumber).HasColumnName("strEPANumber");
            this.Property(t => t.ysnInboundTax).HasColumnName("ysnInboundTax");
            this.Property(t => t.ysnOutboundTax).HasColumnName("ysnOutboundTax");
            this.Property(t => t.ysnRestrictedChemical).HasColumnName("ysnRestrictedChemical");
            this.Property(t => t.ysnFuelItem).HasColumnName("ysnFuelItem");
            this.Property(t => t.ysnTankRequired).HasColumnName("ysnTankRequired");
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull").HasPrecision(18, 6);
            this.Property(t => t.strFuelInspectFee).HasColumnName("strFuelInspectFee");
            this.Property(t => t.strRINRequired).HasColumnName("strRINRequired");
            this.Property(t => t.intRINFuelTypeId).HasColumnName("intRINFuelTypeId");
            this.Property(t => t.dblDenaturantPercent).HasColumnName("dblDenaturantPercent").HasPrecision(18, 6);
            this.Property(t => t.ysnTonnageTax).HasColumnName("ysnTonnageTax");
            this.Property(t => t.ysnLoadTracking).HasColumnName("ysnLoadTracking");
            this.Property(t => t.dblMixOrder).HasColumnName("dblMixOrder").HasPrecision(18, 6);
            this.Property(t => t.ysnHandAddIngredient).HasColumnName("ysnHandAddIngredient");
            this.Property(t => t.intMedicationTag).HasColumnName("intMedicationTag");
            this.Property(t => t.intIngredientTag).HasColumnName("intIngredientTag");
            this.Property(t => t.strVolumeRebateGroup).HasColumnName("strVolumeRebateGroup");
            this.Property(t => t.intPhysicalItem).HasColumnName("intPhysicalItem");
            this.Property(t => t.ysnExtendPickTicket).HasColumnName("ysnExtendPickTicket");
            this.Property(t => t.ysnExportEDI).HasColumnName("ysnExportEDI");
            this.Property(t => t.ysnHazardMaterial).HasColumnName("ysnHazardMaterial");
            this.Property(t => t.ysnMaterialFee).HasColumnName("ysnMaterialFee");
            this.Property(t => t.ysnAutoBlend).HasColumnName("ysnAutoBlend");
            this.Property(t => t.dblUserGroupFee).HasColumnName("dblUserGroupFee").HasPrecision(18, 6);
            this.Property(t => t.dblWeightTolerance).HasColumnName("dblWeightTolerance").HasPrecision(18, 6);
            this.Property(t => t.dblOverReceiveTolerance).HasColumnName("dblOverReceiveTolerance").HasPrecision(18, 6);
            this.Property(t => t.strMaintenanceCalculationMethod).HasColumnName("strMaintenanceCalculationMethod");
            this.Property(t => t.dblMaintenanceRate).HasColumnName("dblMaintenanceRate").HasPrecision(18, 6);
            this.Property(t => t.strNACSCategory).HasColumnName("strNACSCategory");
            this.Property(t => t.strWICCode).HasColumnName("strWICCode");
            this.Property(t => t.intAGCategory).HasColumnName("intAGCategory");
            this.Property(t => t.ysnReceiptCommentRequired).HasColumnName("ysnReceiptCommentRequired");
            this.Property(t => t.strCountCode).HasColumnName("strCountCode");
            this.Property(t => t.ysnLandedCost).HasColumnName("ysnLandedCost");
            this.Property(t => t.strLeadTime).HasColumnName("strLeadTime");
            this.Property(t => t.ysnTaxable).HasColumnName("ysnTaxable");
            this.Property(t => t.strKeywords).HasColumnName("strKeywords");
            this.Property(t => t.dblCaseQty).HasColumnName("dblCaseQty").HasPrecision(18, 6);
            this.Property(t => t.dtmDateShip).HasColumnName("dtmDateShip");
            this.Property(t => t.dblTaxExempt).HasColumnName("dblTaxExempt").HasPrecision(18, 6);
            this.Property(t => t.ysnDropShip).HasColumnName("ysnDropShip");
            this.Property(t => t.ysnCommisionable).HasColumnName("ysnCommisionable");
            this.Property(t => t.ysnSpecialCommission).HasColumnName("ysnSpecialCommission");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.intCommodityHierarchyId).HasColumnName("intCommodityHierarchyId");
            this.Property(t => t.dblGAShrinkFactor).HasColumnName("dblGAShrinkFactor").HasPrecision(18, 6);
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.intProductTypeId).HasColumnName("intProductTypeId");
            this.Property(t => t.intRegionId).HasColumnName("intRegionId");
            this.Property(t => t.intSeasonId).HasColumnName("intSeasonId");
            this.Property(t => t.intClassVarietyId).HasColumnName("intClassVarietyId");
            this.Property(t => t.intProductLineId).HasColumnName("intProductLineId");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strMarketValuation).HasColumnName("strMarketValuation");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnMTM).HasColumnName("ysnMTM");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.strWeightControlCode).HasColumnName("strWeightControlCode");
            this.Property(t => t.dblBlendWeight).HasColumnName("dblBlendWeight").HasPrecision(18, 6);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerCase).HasColumnName("dblUnitPerCase").HasPrecision(18, 6);
            this.Property(t => t.dblQuarantineDuration).HasColumnName("dblQuarantineDuration").HasPrecision(18, 6);
            this.Property(t => t.dblCaseWeight).HasColumnName("dblCaseWeight").HasPrecision(18, 6);
            this.Property(t => t.ysnKosherCertified).HasColumnName("ysnKosherCertified");
            this.Property(t => t.ysnFairTradeCompliant).HasColumnName("ysnFairTradeCompliant");
            this.Property(t => t.ysnOrganic).HasColumnName("ysnOrganic");
            this.Property(t => t.ysnRainForestCertified).HasColumnName("ysnRainForestCertified");
            this.Property(t => t.dblRiskScore).HasColumnName("dblRiskScore").HasPrecision(18, 6);
            this.Property(t => t.dblDensity).HasColumnName("dblDensity").HasPrecision(18, 6);
            this.Property(t => t.dtmDateAvailable).HasColumnName("dtmDateAvailable");
            this.Property(t => t.ysnMinorIngredient).HasColumnName("ysnMinorIngredient");
            this.Property(t => t.ysnExternalItem).HasColumnName("ysnExternalItem");
            this.Property(t => t.ysnSellableItem).HasColumnName("ysnSellableItem");
            this.Property(t => t.dblMinStockWeeks).HasColumnName("dblMinStockWeeks").HasPrecision(18, 6);
            this.Property(t => t.dblFullContainerSize).HasColumnName("dblFullContainerSize").HasPrecision(18, 6);

            this.HasOptional(p => p.tblICBrand)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intBrandId);
            this.HasOptional(p => p.tblICManufacturer)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intManufacturerId);
            this.HasOptional(p => p.tblICCategory)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intCategoryId);
            this.HasOptional(p => p.tblICCommodity)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intCommodityId);

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
            this.HasMany(p => p.tblICItemCommodityCosts)
                .WithRequired(p => p.tblICItem)
                .HasForeignKey(p => p.intItemId);
        }
    }

    public class vyuICGetCompactItemMap : EntityTypeConfiguration<vyuICGetCompactItem>
    {
        public vyuICGetCompactItemMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetCompactItem");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strManufacturer).HasColumnName("strManufacturer");
            this.Property(t => t.strBrandCode).HasColumnName("strBrandCode");
            this.Property(t => t.strBrandName).HasColumnName("strBrandName");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strTracking).HasColumnName("strTracking");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnMTM).HasColumnName("ysnMTM");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
        }
    }

    public class vyuICGetItemCommodityMap : EntityTypeConfiguration<vyuICGetItemCommodity>
    {
        public vyuICGetItemCommodityMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemCommodity");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.strModelNo).HasColumnName("strModelNo");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intBrandId).HasColumnName("intBrandId");
            this.Property(t => t.strBrand).HasColumnName("strBrand");
            this.Property(t => t.intManufacturerId).HasColumnName("intManufacturerId");
            this.Property(t => t.strManufacturer).HasColumnName("strManufacturer");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strTracking).HasColumnName("strTracking");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.strOrigin).HasColumnName("strOrigin");
            this.Property(t => t.intProductTypeId).HasColumnName("intProductTypeId");
            this.Property(t => t.strProductType).HasColumnName("strProductType");
            this.Property(t => t.intRegionId).HasColumnName("intRegionId");
            this.Property(t => t.strRegion).HasColumnName("strRegion");
            this.Property(t => t.intSeasonId).HasColumnName("intSeasonId");
            this.Property(t => t.strSeason).HasColumnName("strSeason");
            this.Property(t => t.intClassVarietyId).HasColumnName("intClassVarietyId");
            this.Property(t => t.strClassVariety).HasColumnName("strClassVariety");
            this.Property(t => t.intProductLineId).HasColumnName("intProductLineId");
            this.Property(t => t.strProductLine).HasColumnName("strProductLine");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
        }
    }

    public class vyuICGetOtherChargesMap : EntityTypeConfiguration<vyuICGetOtherCharges>
    {
        public vyuICGetOtherChargesMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemId);

            // Table & Column Mappings
            this.ToTable("vyuICGetOtherCharges");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnInventoryCost).HasColumnName("ysnInventoryCost");
            this.Property(t => t.ysnAccrue).HasColumnName("ysnAccrue");
            this.Property(t => t.ysnMTM).HasColumnName("ysnMTM");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
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
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.strInventoryTracking).HasColumnName("strInventoryTracking");
            this.Property(t => t.strStatus).HasColumnName("strStatus");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.intStockUOMId).HasColumnName("intStockUOMId");
            this.Property(t => t.strStockUOM).HasColumnName("strStockUOM");
            this.Property(t => t.strStockUOMType).HasColumnName("strStockUOMType");
            this.Property(t => t.dblStockUnitQty).HasColumnName("dblStockUnitQty");
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.dblReceiveUOMConvFactor).HasColumnName("dblReceiveUOMConvFactor").HasPrecision(18, 6);
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.dblIssueUOMConvFactor).HasColumnName("dblIssueUOMConvFactor").HasPrecision(18, 6);
            this.Property(t => t.strReceiveUOMType).HasColumnName("strReceiveUOMType");
            this.Property(t => t.strIssueUOMType).HasColumnName("strIssueUOMType");
            this.Property(t => t.strReceiveUOM).HasColumnName("strReceiveUOM");
            this.Property(t => t.strReceiveUPC).HasColumnName("strReceiveUPC");
            this.Property(t => t.dblReceiveSalePrice).HasColumnName("dblReceiveSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveMSRPPrice).HasColumnName("dblReceiveMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveLastCost).HasColumnName("dblReceiveLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveStandardCost).HasColumnName("dblReceiveStandardCost").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveAverageCost).HasColumnName("dblReceiveAverageCost").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveEndMonthCost).HasColumnName("dblReceiveEndMonthCost").HasPrecision(18, 6);
            this.Property(t => t.strIssueUOM).HasColumnName("strIssueUOM");
            this.Property(t => t.strIssueUPC).HasColumnName("strIssueUPC");
            this.Property(t => t.dblIssueSalePrice).HasColumnName("dblIssueSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblIssueMSRPPrice).HasColumnName("dblIssueMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.dblIssueLastCost).HasColumnName("dblIssueLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblIssueStandardCost).HasColumnName("dblIssueStandardCost").HasPrecision(18, 6);
            this.Property(t => t.dblIssueAverageCost).HasColumnName("dblIssueAverageCost").HasPrecision(18, 6);
            this.Property(t => t.dblIssueEndMonthCost).HasColumnName("dblIssueEndMonthCost").HasPrecision(18, 6);
            this.Property(t => t.dblMinOrder).HasColumnName("dblMinOrder").HasPrecision(18, 6);
            this.Property(t => t.dblReorderPoint).HasColumnName("dblReorderPoint").HasPrecision(18, 6);
            this.Property(t => t.intAllowNegativeInventory).HasColumnName("intAllowNegativeInventory");
            this.Property(t => t.strAllowNegativeInventory).HasColumnName("strAllowNegativeInventory");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.strCostingMethod).HasColumnName("strCostingMethod");
            this.Property(t => t.dblAmountPercent).HasColumnName("dblAmountPercent").HasPrecision(18, 6);
            this.Property(t => t.dblSalePrice).HasColumnName("dblSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblMSRPPrice).HasColumnName("dblMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(18, 6);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(18, 6);
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost").HasPrecision(18, 6);
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand").HasPrecision(18, 6);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(18, 6);
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted").HasPrecision(18, 6);
            this.Property(t => t.dblBackOrder).HasColumnName("dblBackOrder").HasPrecision(18, 6);
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull").HasPrecision(18, 6);
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.dblMaintenanceRate).HasColumnName("dblMaintenanceRate").HasPrecision(18, 6);
            this.Property(t => t.strMaintenanceCalculationMethod).HasColumnName("strMaintenanceCalculationMethod");
            this.Property(t => t.dblOverReceiveTolerance).HasColumnName("dblOverReceiveTolerance").HasPrecision(18, 6);
            this.Property(t => t.dblWeightTolerance).HasColumnName("dblWeightTolerance").HasPrecision(18, 6);
            this.Property(t => t.intSalesTaxGroupId).HasColumnName("intSalesTaxGroupId");
            this.Property(t => t.strSalesTax).HasColumnName("strSalesTax");
            this.Property(t => t.intPurchaseTaxGroupId).HasColumnName("intPurchaseTaxGroupId");
            this.Property(t => t.strPurchaseTax).HasColumnName("strPurchaseTax");
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");

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
            this.Property(t => t.intPricingKey).HasColumnName("intPricingKey");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strUpcCode).HasColumnName("strUpcCode");
            this.Property(t => t.intItemPricingId).HasColumnName("intItemPricingId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(18, 6);
            this.Property(t => t.dblAmountPercent).HasColumnName("dblAmountPercent").HasPrecision(18, 6);
            this.Property(t => t.dblSalePrice).HasColumnName("dblSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblMSRPPrice).HasColumnName("dblMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(18, 6);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(18, 6);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(18, 6);
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost").HasPrecision(18, 6);
            this.Property(t => t.intSort).HasColumnName("intSort");
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
            this.Property(t => t.intAccountCategoryId).HasColumnName("intAccountCategoryId");
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

    public class vyuICGetItemStockUOMMap : EntityTypeConfiguration<vyuICGetItemStockUOM>
    {
        public vyuICGetItemStockUOMMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemStockUOMId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockUOM");
            this.Property(t => t.intItemStockUOMId).HasColumnName("intItemStockUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intLotId).HasColumnName("intLotId");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strLotAlias).HasColumnName("strLotAlias");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(18, 6);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(18, 6);
            this.Property(t => t.dblReservedQty).HasColumnName("dblReservedQty").HasPrecision(18, 6);
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(18, 6);
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(18, 6);
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
        }
    }

    public class vyuICGetItemStockUOMForAdjustmentMap : EntityTypeConfiguration<vyuICGetItemStockUOMForAdjustment>
    {
        public vyuICGetItemStockUOMForAdjustmentMap()
        {
            // Primary Key
            // this.HasKey(p => p.intItemStockUOMId);
            this.HasKey(p => new {                 
                p.intItemId,
                p.intItemUOMId,
                p.intItemStockUOMId,
                p.intItemLocationId,
                p.intSubLocationId,
                p.intStorageLocationId                
            }); 

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockUOMForAdjustment");
            this.Property(t => t.intItemStockUOMId).HasColumnName("intItemStockUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.strType).HasColumnName("strType");
            //this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(18, 6);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(18, 6);
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(18, 6);
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
        }
    }

}
