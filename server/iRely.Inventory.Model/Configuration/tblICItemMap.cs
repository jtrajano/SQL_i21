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
            this.Property(t => t.strShortName).HasColumnName("strShortName");
            this.Property(t => t.strType).HasColumnName("strType");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.strRequired).HasColumnName("strRequired");
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
            this.Property(t => t.dblMaxWeightPerPack).HasColumnName("dblMaxWeightPerPack").HasPrecision(18, 6);
            this.Property(t => t.intPatronageCategoryId).HasColumnName("intPatronageCategoryId");
            this.Property(t => t.intPatronageCategoryDirectId).HasColumnName("intPatronageCategoryDirectId");
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
            this.Property(t => t.ysnListBundleSeparately).HasColumnName("ysnListBundleSeparately");
            this.Property(t => t.intModuleId).HasColumnName("intModuleId");
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
            this.Property(t => t.intM2MComputationId).HasColumnName("intM2MComputationId");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.strCostType).HasColumnName("strCostType");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.intPackTypeId).HasColumnName("intPackTypeId");
            this.Property(t => t.strWeightControlCode).HasColumnName("strWeightControlCode");
            this.Property(t => t.dblBlendWeight).HasColumnName("dblBlendWeight").HasPrecision(18, 6);
            this.Property(t => t.dblNetWeight).HasColumnName("dblNetWeight").HasPrecision(18, 6);
            this.Property(t => t.dblUnitPerCase).HasColumnName("dblUnitPerCase").HasPrecision(18, 6);
            this.Property(t => t.dblQuarantineDuration).HasColumnName("dblQuarantineDuration").HasPrecision(18, 6);
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.intCustomerId).HasColumnName("intCustomerId");
            this.Property(t => t.dblCaseWeight).HasColumnName("dblCaseWeight").HasPrecision(18, 6);
            this.Property(t => t.strWarehouseStatus).HasColumnName("strWarehouseStatus");
            this.Property(t => t.ysnKosherCertified).HasColumnName("ysnKosherCertified");
            this.Property(t => t.ysnFairTradeCompliant).HasColumnName("ysnFairTradeCompliant");
            this.Property(t => t.ysnOrganic).HasColumnName("ysnOrganic");
            this.Property(t => t.ysnRainForestCertified).HasColumnName("ysnRainForestCertified");
            this.Property(t => t.dblRiskScore).HasColumnName("dblRiskScore").HasPrecision(18, 6);
            this.Property(t => t.dblDensity).HasColumnName("dblDensity").HasPrecision(18, 6);
            this.Property(t => t.dtmDateAvailable).HasColumnName("dtmDateAvailable");
            this.Property(t => t.ysnMinorIngredient).HasColumnName("ysnMinorIngredient");
            this.Property(t => t.ysnExternalItem).HasColumnName("ysnExternalItem");
            this.Property(t => t.strExternalGroup).HasColumnName("strExternalGroup");
            this.Property(t => t.ysnSellableItem).HasColumnName("ysnSellableItem");
            this.Property(t => t.dblMinStockWeeks).HasColumnName("dblMinStockWeeks").HasPrecision(18, 6);
            this.Property(t => t.dblFullContainerSize).HasColumnName("dblFullContainerSize").HasPrecision(18, 6);
            this.Property(t => t.ysnHasMFTImplication).HasColumnName("ysnHasMFTImplication");
            this.Property(t => t.ysnItemUsedInDiscountCode).HasColumnName("ysnItemUsedInDiscountCode");
            this.Property(t => t.strInvoiceComments).HasColumnName("strInvoiceComments");
            this.Property(t => t.strPickListComments).HasColumnName("strPickListComments");
            this.Property(t => t.intLotStatusId).HasColumnName("intLotStatusId");
            this.Property(t => t.ysnBasisContract).HasColumnName("ysnBasisContract");
            this.Property(t => t.intTonnageTaxUOMId).HasColumnName("intTonnageTaxUOMId");

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
            this.HasOptional(p => p.tblICM2MComputation)
                .WithMany(p => p.tblICItems)
                .HasForeignKey(p => p.intM2MComputationId);

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
            this.HasMany(p => p.tblICItemMotorFuelTaxes)
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
            this.Property(t => t.strRequired).HasColumnName("strRequired");
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
            this.Property(t => t.intM2MComputationId).HasColumnName("intM2MComputationId");
            this.Property(t => t.strM2MComputation).HasColumnName("strM2MComputation");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.intOriginId).HasColumnName("intOriginId");
            this.Property(t => t.strOriginName).HasColumnName("strOriginName");
            this.Property(t => t.strCostType).HasColumnName("strCostType");
            this.Property(t => t.strShortName).HasColumnName("strShortName");
            this.Property(t => t.ysnBasisContract).HasColumnName("ysnBasisContract");
            this.Property(t => t.intTonnageTaxUOMId).HasColumnName("intTonnageTaxUOMId");
            this.Property(t => t.strTonnageTaxUOM).HasColumnName("strTonnageTaxUOM");

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
            this.Property(t => t.intM2MComputationId).HasColumnName("intM2MComputationId");
            this.Property(t => t.strM2MComputation).HasColumnName("strM2MComputation");
            this.Property(t => t.ysnPrice).HasColumnName("ysnPrice");
            this.Property(t => t.strCostMethod).HasColumnName("strCostMethod");
            this.Property(t => t.dblAmount).HasColumnName("dblAmount").HasPrecision(18, 6);
            this.Property(t => t.intCostUOMId).HasColumnName("intCostUOMId");
            this.Property(t => t.strCostUOM).HasColumnName("strCostUOM");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.strCostType).HasColumnName("strCostType");
            this.Property(t => t.intOnCostTypeId).HasColumnName("intOnCostTypeId");
            this.Property(t => t.strOnCostType).HasColumnName("strOnCostType");
            this.Property(t => t.ysnBasisContract).HasColumnName("ysnBasisContract");
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
            this.Property(t => t.dblStockUnitQty).HasColumnName("dblStockUnitQty").HasPrecision(38, 20);
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.intReceiveUnitMeasureId).HasColumnName("intReceiveUnitMeasureId");
            this.Property(t => t.dblReceiveUOMConvFactor).HasColumnName("dblReceiveUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.intIssueUnitMeasureId).HasColumnName("intIssueUnitMeasureId");
            this.Property(t => t.dblIssueUOMConvFactor).HasColumnName("dblIssueUOMConvFactor").HasPrecision(38, 20);
            this.Property(t => t.strReceiveUOMType).HasColumnName("strReceiveUOMType");
            this.Property(t => t.strIssueUOMType).HasColumnName("strIssueUOMType");
            this.Property(t => t.strReceiveUOM).HasColumnName("strReceiveUOM");
            this.Property(t => t.strReceiveUPC).HasColumnName("strReceiveUPC");
            this.Property(t => t.dblReceiveSalePrice).HasColumnName("dblReceiveSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveMSRPPrice).HasColumnName("dblReceiveMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.dblReceiveLastCost).HasColumnName("dblReceiveLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblReceiveStandardCost).HasColumnName("dblReceiveStandardCost").HasPrecision(38, 20);
            this.Property(t => t.dblReceiveAverageCost).HasColumnName("dblReceiveAverageCost").HasPrecision(38, 20);
            this.Property(t => t.dblReceiveEndMonthCost).HasColumnName("dblReceiveEndMonthCost").HasPrecision(38, 20);
            this.Property(t => t.ysnReceiveUOMAllowPurchase).HasColumnName("ysnReceiveUOMAllowPurchase");
            this.Property(t => t.ysnReceiveUOMAllowSale).HasColumnName("ysnReceiveUOMAllowSale");
            this.Property(t => t.strIssueUOM).HasColumnName("strIssueUOM");
            this.Property(t => t.strIssueUPC).HasColumnName("strIssueUPC");
            this.Property(t => t.dblIssueSalePrice).HasColumnName("dblIssueSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblIssueMSRPPrice).HasColumnName("dblIssueMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.dblIssueLastCost).HasColumnName("dblIssueLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblIssueStandardCost).HasColumnName("dblIssueStandardCost").HasPrecision(38, 20);
            this.Property(t => t.dblIssueAverageCost).HasColumnName("dblIssueAverageCost").HasPrecision(38, 20);
            this.Property(t => t.dblIssueEndMonthCost).HasColumnName("dblIssueEndMonthCost").HasPrecision(38, 20);
            this.Property(t => t.ysnIssueUOMAllowPurchase).HasColumnName("ysnIssueUOMAllowPurchase");
            this.Property(t => t.ysnIssueUOMAllowSale).HasColumnName("ysnIssueUOMAllowSale");
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
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(38, 20);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(38, 20);
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost").HasPrecision(38, 20);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitInbound).HasColumnName("dblInTransitInbound").HasPrecision(38, 20);
            this.Property(t => t.dblUnitOnHand).HasColumnName("dblUnitOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitOutbound).HasColumnName("dblInTransitOutbound").HasPrecision(38, 20);
            this.Property(t => t.dblBackOrder).HasColumnName("dblBackOrder").HasPrecision(38, 20);
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted").HasPrecision(38, 20);
            this.Property(t => t.dblUnitStorage).HasColumnName("dblUnitStorage").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedPurchase).HasColumnName("dblConsignedPurchase").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedSale).HasColumnName("dblConsignedSale").HasPrecision(38, 20);
            this.Property(t => t.dblUnitReserved).HasColumnName("dblUnitReserved").HasPrecision(38, 20);
            this.Property(t => t.dblLastCountRetail).HasColumnName("dblLastCountRetail").HasPrecision(38, 20);
            this.Property(t => t.dblAvailable).HasColumnName("dblAvailable").HasPrecision(38, 20);
            this.Property(t => t.dblDefaultFull).HasColumnName("dblDefaultFull").HasPrecision(18, 6);
            this.Property(t => t.ysnAvailableTM).HasColumnName("ysnAvailableTM");
            this.Property(t => t.dblMaintenanceRate).HasColumnName("dblMaintenanceRate").HasPrecision(18, 6);
            this.Property(t => t.strMaintenanceCalculationMethod).HasColumnName("strMaintenanceCalculationMethod");
            this.Property(t => t.dblOverReceiveTolerance).HasColumnName("dblOverReceiveTolerance").HasPrecision(18, 6);
            this.Property(t => t.dblWeightTolerance).HasColumnName("dblWeightTolerance").HasPrecision(18, 6);
            this.Property(t => t.intGradeId).HasColumnName("intGradeId");
            this.Property(t => t.strGrade).HasColumnName("strGrade");
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
            this.Property(t => t.ysnListBundleSeparately).HasColumnName("ysnListBundleSeparately");
            this.Property(t => t.dblExtendedCost).HasColumnName("dblExtendedCost");
            this.Property(t => t.strRequired).HasColumnName("strRequired");
            this.Property(t => t.intTonnageTaxUOMId).HasColumnName("intTonnageTaxUOMId");
            this.Property(t => t.strTonnageTaxUOM).HasColumnName("strTonnageTaxUOM");
            this.Property(t => t.intModuleId).HasColumnName("intModuleId");
            this.Property(t => t.strModule).HasColumnName("strModule");

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
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strUpcCode).HasColumnName("strUpcCode");
            this.Property(t => t.strLongUPCCode).HasColumnName("strLongUPCCode");
            this.Property(t => t.intItemPricingId).HasColumnName("intItemPricingId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intItemUnitMeasureId).HasColumnName("intItemUnitMeasureId");
            this.Property(t => t.intUnitMeasureId).HasColumnName("intUnitMeasureId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.strUnitType).HasColumnName("strUnitType");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.ysnAllowPurchase).HasColumnName("ysnAllowPurchase");
            this.Property(t => t.ysnAllowSale).HasColumnName("ysnAllowSale");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.dblAmountPercent).HasColumnName("dblAmountPercent").HasPrecision(18, 6);
            this.Property(t => t.dblSalePrice).HasColumnName("dblSalePrice").HasPrecision(18, 6);
            this.Property(t => t.dblMSRPPrice).HasColumnName("dblMSRPPrice").HasPrecision(18, 6);
            this.Property(t => t.strPricingMethod).HasColumnName("strPricingMethod");
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(38, 20);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(38, 20);
            this.Property(t => t.dblEndMonthCost).HasColumnName("dblEndMonthCost").HasPrecision(38, 20);
            this.Property(t => t.intSort).HasColumnName("intSort");
            this.Property(t => t.intDecimalPlaces).HasColumnName("intDecimalPlaces");
        }
    }

    public class vyuICGetItemLocationMap : EntityTypeConfiguration<vyuICGetItemLocation>
    {
        public vyuICGetItemLocationMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemLocationId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemLocation");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.strLocationType).HasColumnName("strLocationType");
            this.Property(t => t.intVendorId).HasColumnName("intVendorId");
            this.Property(t => t.strVendorId).HasColumnName("strVendorId");
            this.Property(t => t.strVendorName).HasColumnName("strVendorName");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.intCostingMethod).HasColumnName("intCostingMethod");
            this.Property(t => t.strCostingMethod).HasColumnName("strCostingMethod");
            this.Property(t => t.intAllowNegativeInventory).HasColumnName("intAllowNegativeInventory");
            this.Property(t => t.strAllowNegativeInventory).HasColumnName("strAllowNegativeInventory");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.intIssueUOMId).HasColumnName("intIssueUOMId");
            this.Property(t => t.strIssueUOM).HasColumnName("strIssueUOM");
            this.Property(t => t.intReceiveUOMId).HasColumnName("intReceiveUOMId");
            this.Property(t => t.strReceiveUOM).HasColumnName("strReceiveUOM");
            this.Property(t => t.intFamilyId).HasColumnName("intFamilyId");
            this.Property(t => t.strFamily).HasColumnName("strFamily");
            this.Property(t => t.intClassId).HasColumnName("intClassId");
            this.Property(t => t.strClass).HasColumnName("strClass");
            this.Property(t => t.intProductCodeId).HasColumnName("intProductCodeId");
            this.Property(t => t.strPassportFuelId1).HasColumnName("strPassportFuelId1");
            this.Property(t => t.strPassportFuelId2).HasColumnName("strPassportFuelId2");
            this.Property(t => t.strPassportFuelId3).HasColumnName("strPassportFuelId3");
            this.Property(t => t.ysnTaxFlag1).HasColumnName("ysnTaxFlag1");
            this.Property(t => t.ysnTaxFlag2).HasColumnName("ysnTaxFlag2");
            this.Property(t => t.ysnTaxFlag3).HasColumnName("ysnTaxFlag3");
            this.Property(t => t.ysnTaxFlag4).HasColumnName("ysnTaxFlag4");
            this.Property(t => t.ysnPromotionalItem).HasColumnName("ysnPromotionalItem");
            this.Property(t => t.intMixMatchId).HasColumnName("intMixMatchId");
            this.Property(t => t.strPromoItemListId).HasColumnName("strPromoItemListId");
            this.Property(t => t.ysnDepositRequired).HasColumnName("ysnDepositRequired");
            this.Property(t => t.intDepositPLUId).HasColumnName("intDepositPLUId");
            this.Property(t => t.strDepositPLU).HasColumnName("strDepositPLU");
            this.Property(t => t.intBottleDepositNo).HasColumnName("intBottleDepositNo");
            this.Property(t => t.ysnSaleable).HasColumnName("ysnSaleable");
            this.Property(t => t.ysnQuantityRequired).HasColumnName("ysnQuantityRequired");
            this.Property(t => t.ysnScaleItem).HasColumnName("ysnScaleItem");
            this.Property(t => t.ysnFoodStampable).HasColumnName("ysnFoodStampable");
            this.Property(t => t.ysnReturnable).HasColumnName("ysnReturnable");
            this.Property(t => t.ysnPrePriced).HasColumnName("ysnPrePriced");
            this.Property(t => t.ysnOpenPricePLU).HasColumnName("ysnOpenPricePLU");
            this.Property(t => t.ysnLinkedItem).HasColumnName("ysnLinkedItem");
            this.Property(t => t.strVendorCategory).HasColumnName("strVendorCategory");
            this.Property(t => t.ysnCountBySINo).HasColumnName("ysnCountBySINo");
            this.Property(t => t.strSerialNoBegin).HasColumnName("strSerialNoBegin");
            this.Property(t => t.strSerialNoEnd).HasColumnName("strSerialNoEnd");
            this.Property(t => t.ysnIdRequiredLiquor).HasColumnName("ysnIdRequiredLiquor");
            this.Property(t => t.ysnIdRequiredCigarette).HasColumnName("ysnIdRequiredCigarette");
            this.Property(t => t.intMinimumAge).HasColumnName("intMinimumAge");
            this.Property(t => t.ysnApplyBlueLaw1).HasColumnName("ysnApplyBlueLaw1");
            this.Property(t => t.ysnApplyBlueLaw2).HasColumnName("ysnApplyBlueLaw2");
            this.Property(t => t.ysnCarWash).HasColumnName("ysnCarWash");
            this.Property(t => t.intItemTypeCode).HasColumnName("intItemTypeCode");
            this.Property(t => t.strItemTypeCode).HasColumnName("strItemTypeCode");
            this.Property(t => t.intItemTypeSubCode).HasColumnName("intItemTypeSubCode");
            this.Property(t => t.ysnAutoCalculateFreight).HasColumnName("ysnAutoCalculateFreight");
            this.Property(t => t.intFreightMethodId).HasColumnName("intFreightMethodId");
            this.Property(t => t.strFreightTerm).HasColumnName("strFreightTerm");
            this.Property(t => t.dblFreightRate).HasColumnName("dblFreightRate").HasPrecision(18, 6);
            this.Property(t => t.intShipViaId).HasColumnName("intShipViaId");
            this.Property(t => t.strShipVia).HasColumnName("strShipVia");
            this.Property(t => t.dblReorderPoint).HasColumnName("dblReorderPoint").HasPrecision(18, 6);
            this.Property(t => t.dblMinOrder).HasColumnName("dblMinOrder").HasPrecision(18, 6);
            this.Property(t => t.dblSuggestedQty).HasColumnName("dblSuggestedQty").HasPrecision(18, 6);
            this.Property(t => t.dblLeadTime).HasColumnName("dblLeadTime").HasPrecision(18, 6);
            this.Property(t => t.strCounted).HasColumnName("strCounted");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strCountGroup).HasColumnName("strCountGroup");
            this.Property(t => t.ysnCountedDaily).HasColumnName("ysnCountedDaily");
            this.Property(t => t.ysnLockedInventory).HasColumnName("ysnLockedInventory");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblSTSubcategoryRegProd)
               .WithMany(p => p.vyuICGetItemLocation)
               .HasForeignKey(p => p.intProductCodeId);
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

    public class vyuICGetItemStockUOMTotalsMap : EntityTypeConfiguration<vyuICGetItemStockUOMTotals>
    {
        public vyuICGetItemStockUOMTotalsMap()
        {
            this.HasKey(p => p.intItemStockUOMId);
            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockUOMTotals");
            this.Property(t => t.intItemStockUOMId).HasColumnName("intItemStockUOMId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty");
            this.Property(t => t.dblStorageQty).HasColumnName("dblStorageQty");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
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
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intCommodityId).HasColumnName("intCommodityId");
            this.Property(t => t.strCommodity).HasColumnName("strCommodity");
            this.Property(t => t.strLotTracking).HasColumnName("strLotTracking");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intCountGroupId).HasColumnName("intCountGroupId");
            this.Property(t => t.strCountGroup).HasColumnName("strCountGroup");
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
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblStorageQty).HasColumnName("dblStorageQty").HasPrecision(38, 20);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(38, 20);
            this.Property(t => t.dblReservedQty).HasColumnName("dblReservedQty").HasPrecision(38, 20);
            this.Property(t => t.dblAvailableQty).HasColumnName("dblAvailableQty").HasPrecision(38, 20);
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);

            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
            this.Property(t => t.dblStockUnitCost).HasColumnName("dblStockUnitCost").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.intLifeTime).HasColumnName("intLifeTime");
            this.Property(t => t.strLifeTimeType).HasColumnName("strLifeTimeType");
        }
    }

    public class vyuICGetItemStockUOMSummaryMap : EntityTypeConfiguration<vyuICGetItemStockUOMSummary>
    {
        public vyuICGetItemStockUOMSummaryMap()
        {
            // Primary Key
            this.HasKey(p => p.intKey);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemStockUOMSummary");
            this.Property(t => t.intKey).HasColumnName("intKey");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intItemUOMId).HasColumnName("intItemUOMId");
            this.Property(t => t.strUnitMeasure).HasColumnName("strUnitMeasure");
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblInConsigned).HasColumnName("dblInConsigned").HasPrecision(38, 20);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(38, 20);
            this.Property(t => t.dblOrderCommitted).HasColumnName("dblOrderCommitted").HasPrecision(38, 20);
            this.Property(t => t.dblUnitReserved).HasColumnName("dblUnitReserved").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitInbound).HasColumnName("dblInTransitInbound").HasPrecision(38, 20);
            this.Property(t => t.dblInTransitOutbound).HasColumnName("dblInTransitOutbound").HasPrecision(38, 20);
            this.Property(t => t.dblUnitStorage).HasColumnName("dblUnitStorage").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedPurchase).HasColumnName("dblConsignedPurchase").HasPrecision(38, 20);
            this.Property(t => t.dblConsignedSale).HasColumnName("dblConsignedSale").HasPrecision(38, 20);
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
            this.Property(t => t.dblOnHand).HasColumnName("dblOnHand").HasPrecision(38, 20);
            this.Property(t => t.dblOnOrder).HasColumnName("dblOnOrder").HasPrecision(38, 20);
            this.Property(t => t.dblUnitQty).HasColumnName("dblUnitQty").HasPrecision(38, 20);
            this.Property(t => t.ysnStockUnit).HasColumnName("ysnStockUnit");
        }
    }

    public class vyuICGetInventoryValuationMap : EntityTypeConfiguration<vyuICGetInventoryValuation>
    {
        public vyuICGetInventoryValuationMap()
        {
            // Primary Key
            //this.HasKey(p => p.intInventoryValuationKeyId);
            this.HasKey(p => new
            {
                p.intItemId,
                p.intInventoryTransactionId
            }); 

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryValuation");
            this.Property(t => t.intInventoryValuationKeyId).HasColumnName("intInventoryValuationKeyId");
            this.Property(t => t.intInventoryTransactionId).HasColumnName("intInventoryTransactionId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intCategoryId).HasColumnName("intCategoryId");
            this.Property(t => t.strCategory).HasColumnName("strCategory");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intStorageLocationId).HasColumnName("intStorageLocationId");
            this.Property(t => t.strStorageLocationName).HasColumnName("strStorageLocationName");
            this.Property(t => t.strBOLNumber).HasColumnName("strBOLNumber");
            this.Property(t => t.strEntity).HasColumnName("strEntity");
            this.Property(t => t.strLotNumber).HasColumnName("strLotNumber");
            this.Property(t => t.strAdjustedTransaction).HasColumnName("strAdjustedTransaction");
            this.Property(t => t.dtmDate).HasColumnName("dtmDate");
            this.Property(t => t.strTransactionType).HasColumnName("strTransactionType");
            this.Property(t => t.strTransactionForm).HasColumnName("strTransactionForm");
            this.Property(t => t.strTransactionId).HasColumnName("strTransactionId");
            this.Property(t => t.dblBeginningQtyBalance).HasColumnName("dblBeginningQtyBalance").HasPrecision(38, 20);
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblRunningQtyBalance).HasColumnName("dblRunningQtyBalance").HasPrecision(38, 20);
            this.Property(t => t.dblCost).HasColumnName("dblCost").HasPrecision(38, 20);
            this.Property(t => t.dblBeginningBalance).HasColumnName("dblBeginningBalance").HasPrecision(38, 20);
            this.Property(t => t.dblValue).HasColumnName("dblValue").HasPrecision(38, 20);
            this.Property(t => t.dblRunningBalance).HasColumnName("dblRunningBalance").HasPrecision(38, 20);
            this.Property(t => t.strBatchId).HasColumnName("strBatchId");
            this.Property(t => t.strCostingMethod).HasColumnName("strCostingMethod");
            this.Property(t => t.strUOM).HasColumnName("strUOM");
            this.Property(t => t.strStockUOM).HasColumnName("strStockUOM");
            this.Property(t => t.dblQuantityInStockUOM).HasColumnName("dblQuantityInStockUOM");
            this.Property(t => t.dblCostInStockUOM).HasColumnName("dblCostInStockUOM");
        }
    }

    class vyuICGetInventoryValuationSummaryMap : EntityTypeConfiguration<vyuICGetInventoryValuationSummary>
    {
        public vyuICGetInventoryValuationSummaryMap()
        {
            // Primary Key
            this.HasKey(p => p.intInventoryValuationKeyId);

            // Table & Column Mappings
            this.ToTable("vyuICGetInventoryValuationSummary");
            this.Property(t => t.intInventoryValuationKeyId).HasColumnName("intInventoryValuationKeyId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.strItemDescription).HasColumnName("strItemDescription");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strLocationName).HasColumnName("strLocationName");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.dblQuantity).HasColumnName("dblQuantity").HasPrecision(38, 20);
            this.Property(t => t.dblValue).HasColumnName("dblValue").HasPrecision(38, 20);
            this.Property(t => t.dblLastCost).HasColumnName("dblLastCost").HasPrecision(38, 20);
            this.Property(t => t.dblStandardCost).HasColumnName("dblStandardCost").HasPrecision(38, 20);
            this.Property(t => t.dblAverageCost).HasColumnName("dblAverageCost").HasPrecision(38, 20);
            this.Property(t => t.strStockUOM).HasColumnName("strStockUOM");
            this.Property(t => t.dblQuantityInStockUOM).HasColumnName("dblQuantityInStockUOM").HasPrecision(38, 20);
            this.Property(t => t.strCategoryCode).HasColumnName("strCategoryCode");
            this.Property(t => t.strCommodityCode).HasColumnName("strCommodityCode");
            this.Property(t => t.strInTransitLocationName).HasColumnName("strInTransitLocationName");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intInTransitLocationId).HasColumnName("intInTransitLocationId");
        }
    }

    public class vyuICGetItemOwnerMap : EntityTypeConfiguration<vyuICGetItemOwner>
    {
        public vyuICGetItemOwnerMap()
        {
            // Primary Key
            this.HasKey(p => p.intItemOwnerId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemOwner");
            this.Property(t => t.intItemOwnerId).HasColumnName("intItemOwnerId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intOwnerId).HasColumnName("intOwnerId");
            this.Property(t => t.strName).HasColumnName("strName");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
        }
    }

    public class vyuICItemSubLocationsMap: EntityTypeConfiguration<vyuICItemSubLocations>
    {
        public vyuICItemSubLocationsMap()
        {
            this.HasKey(p => p.intItemSubLocationId);
            this.ToTable("vyuICItemSubLocations");
            this.Property(t => t.intItemSubLocationId).HasColumnName("intItemSubLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intConcurrencyId).HasColumnName("intConcurrencyId");
        }
    }

    public class vyuICGetItemSubLocationsMap : EntityTypeConfiguration<vyuICGetItemSubLocations>
    {
        public vyuICGetItemSubLocationsMap()
        {
            // Primary Key
            this.HasKey(p => p.intId);

            // Table & Column Mappings
            this.ToTable("vyuICGetItemSubLocations");
            this.Property(t => t.intId).HasColumnName("intId");
            this.Property(t => t.strItemNo).HasColumnName("strItemNo");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intLocationId).HasColumnName("intLocationId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.intSubLocationId).HasColumnName("intSubLocationId");
            this.Property(t => t.strSubLocationName).HasColumnName("strSubLocationName");
            this.Property(t => t.intCountryId).HasColumnName("intCountryId");
        }
    }

}
