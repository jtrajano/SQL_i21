using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using iRely.Common;

namespace iRely.Inventory.Model
{
    public class tblICItem : BaseEntity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strShortName { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intManufacturerId { get; set; }
        public int? intBrandId { get; set; }
        public int? intCategoryId { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strInventoryTracking { get; set; }
        public string strLotTracking { get; set; }
        public bool? ysnRequireCustomerApproval { get; set; }
        public int? intRecipeId { get; set; }
        public bool? ysnSanitationRequired { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public int? intReceiveLife { get; set; }
        public string strGTIN { get; set; }
        public string strRotationType { get; set; }
        public int? intNMFCId { get; set; }
        public bool? ysnStrictFIFO { get; set; }
        public int? intDimensionUOMId { get; set; }
        public decimal? dblHeight { get; set; }
        public decimal? dblWidth { get; set; }
        public decimal? dblDepth { get; set; }
        public int? intWeightUOMId { get; set; }
        public decimal? dblWeight { get; set; }
        public int? intMaterialPackTypeId { get; set; }
        public string strMaterialSizeCode { get; set; }
        public int? intInnerUnits { get; set; }
        public int? intLayerPerPallet { get; set; }
        public int? intUnitPerLayer { get; set; }
        public decimal? dblStandardPalletRatio { get; set; }
        public string strMask1 { get; set; }
        public string strMask2 { get; set; }
        public string strMask3 { get; set; }
        public decimal? dblMaxWeightPerPack { get; set; }
        public int? intPatronageCategoryId { get; set; }
        public int? intPatronageCategoryDirectId { get; set; }
        public bool? ysnStockedItem { get; set; }
        public bool? ysnDyedFuel { get; set; }
        public string strBarcodePrint { get; set; }
        public bool? ysnMSDSRequired { get; set; }
        public string strEPANumber { get; set; }
        public bool? ysnInboundTax { get; set; }
        public bool? ysnOutboundTax { get; set; }
        public bool? ysnRestrictedChemical { get; set; }
        public bool? ysnFuelItem { get; set; }
        public bool? ysnTankRequired { get; set; }
        public bool? ysnAvailableTM { get; set; }
        public decimal? dblDefaultFull { get; set; }
        public string strFuelInspectFee { get; set; }
        public string strRINRequired { get; set; }
        public int? intRINFuelTypeId { get; set; }
        public decimal? dblDenaturantPercent { get; set; }
        public bool? ysnTonnageTax { get; set; }
        public bool? ysnLoadTracking { get; set; }
        public decimal? dblMixOrder { get; set; }
        public bool? ysnHandAddIngredient { get; set; }
        public int? intMedicationTag { get; set; }
        public int? intIngredientTag { get; set; }
        public int? intItemMessage { get; set; }
        public int? intHazmatMessage { get; set; }
        public string strVolumeRebateGroup { get; set; }
        public int? intPhysicalItem { get; set; }
        public bool? ysnExtendPickTicket { get; set; }
        public bool? ysnExportEDI { get; set; }
        public bool? ysnHazardMaterial { get; set; }
        public bool? ysnMaterialFee { get; set; }
        public bool? ysnAutoBlend { get; set; }
        public decimal? dblUserGroupFee { get; set; }
        public decimal? dblWeightTolerance { get; set; }
        public decimal? dblOverReceiveTolerance { get; set; }
        public string strMaintenanceCalculationMethod { get; set; }
        public decimal? dblMaintenanceRate { get; set; }
        public bool? ysnListBundleSeparately { get; set; }
        public int? intModuleId { get; set; }

        public string strNACSCategory { get; set; }
        public string strWICCode { get; set; }
        public int? intAGCategory { get; set; }
        public bool? ysnReceiptCommentRequired { get; set; }
        public string strCountCode { get; set; }
        public bool? ysnLandedCost { get; set; }
        public string strLeadTime { get; set; }
        public bool? ysnTaxable { get; set; }
        public string strKeywords { get; set; }
        public decimal? dblCaseQty { get; set; }
        public DateTime? dtmDateShip { get; set; }
        public decimal? dblTaxExempt { get; set; }
        public bool? ysnDropShip { get; set; }
        public bool? ysnCommisionable { get; set; }
        public bool? ysnSpecialCommission { get; set; }
        public int? intCommodityId { get; set; }
        public int? intCommodityHierarchyId { get; set; }
        public decimal? dblGAShrinkFactor { get; set; }
        public int? intOriginId { get; set; }
        public int? intProductTypeId { get; set; }
        public int? intRegionId { get; set; }
        public int? intSeasonId { get; set; }
        public int? intClassVarietyId { get; set; }
        public int? intProductLineId { get; set; }
        public int? intGradeId { get; set; }
        public string strMarketValuation { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public string strCostType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public int? intPackTypeId { get; set; }
        public string strWeightControlCode { get; set; }
        public decimal? dblBlendWeight { get; set; }
        public decimal? dblNetWeight { get; set; }
        public decimal? dblUnitPerCase { get; set; }
        public decimal? dblQuarantineDuration { get; set; }
        public int? intOwnerId { get; set; }
        public int? intCustomerId { get; set; }
        public decimal? dblCaseWeight { get; set; }
        public string strWarehouseStatus { get; set; }
        public bool? ysnKosherCertified { get; set; }
        public bool? ysnFairTradeCompliant { get; set; }
        public bool? ysnOrganic { get; set; }
        public bool? ysnRainForestCertified { get; set; }
        public decimal? dblRiskScore { get; set; }
        public decimal? dblDensity { get; set; }
        public DateTime? dtmDateAvailable { get; set; }
        public bool? ysnMinorIngredient { get; set; }
        public bool? ysnExternalItem { get; set; }
        public string strExternalGroup { get; set; }
        public bool? ysnSellableItem { get; set; }
        public decimal? dblMinStockWeeks { get; set; }
        public decimal? dblFullContainerSize { get; set; }
        public bool? ysnHasMFTImplication { get; set; }
        public bool? ysnItemUsedInDiscountCode { get; set; }
        public string strInvoiceComments { get; set; }
        public string strPickListComments { get; set; }
        public int? intLotStatusId { get; set; }
        public string strRequired { get; set; }
        public bool? ysnBasisContract { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public bool? ysnUseWeighScales { get; set; }

        private string _strM2MComputation;
        [NotMapped]
        public string strM2MComputation
        {
            get
            {
                if (string.IsNullOrEmpty(_strM2MComputation))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strM2MComputation;
                    else
                        return null;
                else
                    return _strM2MComputation;
            }
            set
            {
                _strM2MComputation = value;
            }
        }

        private string _manufacturer;
        [NotMapped]
        public string strManufacturer
        {
            get
            {
                if (string.IsNullOrEmpty(_manufacturer))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strManufacturer;
                    else
                        return null;
                else
                    return _manufacturer;
            }
            set
            {
                _manufacturer = value;
            }
        }

        private string _category;
        [NotMapped]
        public string strCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_category))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strCategory;
                    else
                        return null;
                else
                    return _category;
            }
            set
            {
                _category = value;
            }
        }

        private string _brand;
        [NotMapped]
        public string strBrand
        {
            get
            {
                if (string.IsNullOrEmpty(_brand))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strBrandCode;
                    else
                        return null;
                else
                    return _brand;
            }
            set
            {
                _brand = value;
            }
        }
        private string _commodityCode;
        [NotMapped]
        public string strCommodityCode
        {
            get
            {
                if (string.IsNullOrEmpty(_commodityCode))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strCommodity;
                    else
                        return null;
                else
                    return _commodityCode;
            }
            set
            {
                _commodityCode = value;
            }
        }

        private string _fuelCategory;
        
        [NotMapped]
        public string strFuelCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_fuelCategory))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strFuelCategory;
                    else
                        return null;
                else
                    return _fuelCategory;
            }
            set
            {
                _fuelCategory = value;
            }
        }

        private string _medicationTag;
        
        [NotMapped]
        public string strMedicationTag
        {
            get
            {
                if (string.IsNullOrEmpty(_medicationTag))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strMedicationTag;
                    else
                        return null;
                else
                    return _medicationTag;
            }
            set
            {
                _medicationTag = value;
            }
        }

        private string _hazmatMessage;

        [NotMapped]
        public string strHazmatMessage
        {
            get
            {
                if (string.IsNullOrEmpty(_hazmatMessage))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strHazmatMessage;
                    else
                        return null;
                else
                    return _hazmatMessage;
            }
            set
            {
                _hazmatMessage = value;
            }
        }

        private string _itemMessage;

        [NotMapped]
        public string strItemMessage
        {
            get
            {
                if (string.IsNullOrEmpty(_itemMessage))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strItemMessage;
                    else
                        return null;
                else
                    return _itemMessage;
            }
            set
            {
                _itemMessage = value;
            }
        }

        private string _ingredientTag;
        
        [NotMapped]
        public string strIngredientTag
        {
            get
            {
                if (string.IsNullOrEmpty(_ingredientTag))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strIngredientTag;
                    else
                        return null;
                else
                    return _ingredientTag;
            }
            set
            {
                _ingredientTag = value;
            }
        }

        private string _physicalItem;
        
        [NotMapped]
        public string strPhysicalItem
        {
            get
            {
                if (string.IsNullOrEmpty(_physicalItem))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strPhysicalItem;
                    else
                        return null;
                else
                    return _physicalItem;
            }
            set
            {
                _physicalItem = value;
            }
        }

        private string _patronageCategory;
        
        [NotMapped]
        public string strPatronageCategory
        {
            get
            {
                if (string.IsNullOrEmpty(_patronageCategory))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strPatronageCategory;
                    else
                        return null;
                else
                    return _patronageCategory;
            }
            set
            {
                _patronageCategory = value;
            }
        }

        private string _patronageDirect;
       
        [NotMapped]
        public string strPatronageDirect
        {
            get
            {
                if (string.IsNullOrEmpty(_patronageDirect))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strPatronageDirect;
                    else
                        return null;
                else
                    return _patronageDirect;
            }
            set
            {
                _patronageDirect = value;
            }
        }

        private string _origin;
        
        [NotMapped]
        public string strOrigin
        {
            get
            {
                if (string.IsNullOrEmpty(_origin))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strOrigin;
                    else
                        return null;
                else
                    return _origin;
            }
            set
            {
                _origin = value;
            }
        }

        private string _productType;
        
        [NotMapped]
        public string strProductType
        {
            get
            {
                if (string.IsNullOrEmpty(_productType))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strProductType;
                    else
                        return null;
                else
                    return _productType;
            }
            set
            {
                _productType = value;
            }
        }

        private string _region;
        
        [NotMapped]
        public string strRegion
        {
            get
            {
                if (string.IsNullOrEmpty(_region))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strRegion;
                    else
                        return null;
                else
                    return _region;
            }
            set
            {
                _region = value;
            }
        }

        private string _season;
        
        [NotMapped]
        public string strSeason
        {
            get
            {
                if (string.IsNullOrEmpty(_season))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strSeason;
                    else
                        return null;
                else
                    return _season;
            }
            set
            {
                _season = value;
            }
        }

        private string _class;
        
        [NotMapped]
        public string strClass
        {
            get
            {
                if (string.IsNullOrEmpty(_class))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strClass;
                    else
                        return null;
                else
                    return _class;
            }
            set
            {
                _class = value;
            }
        }

        private string _productLine;

        [NotMapped]
        public string strProductLine
        {
            get
            {
                if (string.IsNullOrEmpty(_productLine))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strProductLine;
                    else
                        return null;
                else
                    return _productLine;
            }
            set
            {
                _productLine = value;
            }
        }

        public vyuICGetCompactItem vyuICGetCompactItem { get; set; }

        public tblICManufacturer tblICManufacturer { get; set; }
        public tblICM2MComputation tblICM2MComputation { get; set; }
        public tblICBrand tblICBrand { get; set; }
        public tblICCategory tblICCategory { get; set; }
        public tblICCommodity tblICCommodity { get; set; } 

        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }

        public ICollection<tblICItemPOSSLA> tblICItemPOSSLAs { get; set; }
        public ICollection<tblICItemPOSCategory> tblICItemPOSCategories { get; set; }

        public ICollection<tblICItemUPC> tblICItemUPCs { get; set; }
        public ICollection<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public ICollection<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public ICollection<tblICItemContract> tblICItemContracts { get; set; }
        public ICollection<tblICItemCertification> tblICItemCertifications { get; set; }
        public ICollection<tblICItemFactory> tblICItemFactories { get; set; }
        public ICollection<tblICItemPricing> tblICItemPricings { get; set; }
        public ICollection<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public ICollection<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
        public ICollection<tblICItemStock> tblICItemStocks { get; set; }
        public ICollection<tblICItemAccount> tblICItemAccounts { get; set; }
        public ICollection<tblICItemNote> tblICItemNotes { get; set; }
        public ICollection<tblICItemOwner> tblICItemOwners { get; set; }
        public ICollection<tblICItemKit> tblICItemKits { get; set; }
        public ICollection<tblICItemKitDetail> tblICItemKitDetails { get; set; }
        public ICollection<tblICItemBundle> tblICItemBundles { get; set; }
        public ICollection<tblICItemBundle> BundleItems { get; set; }
        public ICollection<tblICItemAssembly> tblICItemAssemblies { get; set; }
        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public ICollection<tblICItemCommodityCost> tblICItemCommodityCosts { get; set; }
        public ICollection<tblICBuildAssembly> tblICBuildAssemblies { get; set; }
        public ICollection<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }

        public ICollection<tblICItemMotorFuelTax> tblICItemMotorFuelTaxes { get; set; }
                
    }

    public class vyuICGetCompactItem
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strManufacturer { get; set; }
        public string strBrandCode { get; set; }
        public string strBrandName { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strTracking { get; set; }
        public string strLotTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public int? intOriginId { get; set; }
        public string strOriginName { get; set; }
        public string strCostType { get; set; }
        public string strShortName { get; set; }
        public string strRequired { get; set; }
        public bool? ysnBasisContract { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public string strTonnageTaxUOM { get; set; }

        public string strFuelCategory { get; set; }
        public string strMedicationTag { get; set; }
        public string strIngredientTag { get; set; }
        public string strHazmatMessage { get; set; }
        public string strItemMessage { get; set; }
        public string strPhysicalItem { get; set; }
        public string strPatronageCategory { get; set; }
        public string strPatronageDirect { get; set; }
        public string strOrigin { get; set; }
        public string strProductType { get; set; }
        public string strRegion { get; set; }
        public string strSeason { get; set; }
        public string strClass { get; set; }
        public string strProductLine { get; set; }

        public tblICItem tblICItem { get; set; }
    }

    public class vyuICGetItemCommodity
    {
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strLotTracking { get; set; }
        public int? intBrandId { get; set; }
        public string strBrand { get; set; }
        public int? intManufacturerId { get; set; }
        public string strManufacturer { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intLocationId { get; set; }
        public string strTracking { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public int? intOriginId { get; set; }
        public string strOrigin { get; set; }
        public int? intProductTypeId { get; set; }
        public string strProductType { get; set; }
        public int? intRegionId { get; set; }
        public string strRegion { get; set; }
        public int? intSeasonId { get; set; }
        public string strSeason { get; set; }
        public int? intClassVarietyId { get; set; }
        public string strClassVariety { get; set; }
        public int? intProductLineId { get; set; }
        public string strProductLine { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
    }

    public class vyuICGetOtherCharges
    {
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strDescription { get; set; }
        public bool? ysnInventoryCost { get; set; }
        public bool? ysnAccrue { get; set; }
        public bool? ysnMTM { get; set; }
        public int? intM2MComputationId { get; set; }
        public string strM2MComputation { get; set; }
        public bool? ysnPrice { get; set; }
        public string strCostMethod { get; set; }
        public decimal? dblAmount { get; set; }
        public int? intCostUOMId { get; set; }
        public string strCostUOM { get; set; }
        public string strUnitType { get; set; }
        public string strCostType { get; set; }
        public int? intOnCostTypeId { get; set; }
        public string strOnCostType { get; set; }
        public bool? ysnBasisContract { get; set; }
    }

    public class vyuICGetItemStock
    {
        [Key]
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strLotTracking { get; set; }
        public string strInventoryTracking { get; set; }
        public string strStatus { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public string strStorageLocationName { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public string strStockUOMType { get; set; }
        public decimal? dblStockUnitQty { get; set; }
        public int? intReceiveUOMId { get; set; }
        public int? intReceiveUnitMeasureId { get; set; }
        public decimal? dblReceiveUOMConvFactor { get; set; }
        public int? intIssueUOMId { get; set; }
        public int? intIssueUnitMeasureId { get; set; }
        public decimal? dblIssueUOMConvFactor { get; set; }
        public string strReceiveUOMType { get; set; }
        public string strIssueUOMType { get; set; }
        public string strReceiveUOM { get; set; }
        public string strReceiveUPC { get; set; }
        public decimal? dblReceiveSalePrice { get; set; }
        public decimal? dblReceiveMSRPPrice { get; set; }
        public decimal? dblReceiveLastCost { get; set; }
        public decimal? dblReceiveStandardCost { get; set; }
        public decimal? dblReceiveAverageCost { get; set; }
        public decimal? dblReceiveEndMonthCost { get; set; }
        public bool? ysnReceiveUOMAllowPurchase { get; set; }
        public bool? ysnReceiveUOMAllowSale { get; set; }
        public string strIssueUOM { get; set; }
        public string strIssueUPC { get; set; }
        public decimal? dblIssueSalePrice { get; set; }
        public decimal? dblIssueMSRPPrice { get; set; }
        public decimal? dblIssueLastCost { get; set; }
        public decimal? dblIssueStandardCost { get; set; }
        public decimal? dblIssueAverageCost { get; set; }
        public decimal? dblIssueEndMonthCost { get; set; }
        public bool? ysnIssueUOMAllowPurchase { get; set; }
        public bool? ysnIssueUOMAllowSale { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblLastCountRetail { get; set; }
        public decimal? dblAvailable { get; set; }
        //public decimal? dblStorageQty { get; set; }
        public decimal? dblDefaultFull { get; set; }
        public bool? ysnAvailableTM { get; set; }
        public decimal? dblMaintenanceRate { get; set; }
        public string strMaintenanceCalculationMethod { get; set; }
        public decimal? dblOverReceiveTolerance { get; set; }
        public decimal? dblWeightTolerance { get; set; }
        public int? intGradeId { get; set; }
        public string strGrade { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public bool? ysnListBundleSeparately { get; set; }
        public decimal? dblExtendedCost { get; set; }
        public string strRequired { get; set; }
        public int? intTonnageTaxUOMId { get; set; }
        public string strTonnageTaxUOM { get; set; }
        public int? intModuleId { get; set; }
        public string strModule { get; set; }
        public bool? ysnUseWeighScales { get; set; }

        public ICollection<vyuICGetItemPricing> tblICItemPricings { get; set; }
        public ICollection<vyuICGetItemAccount> tblICItemAccounts { get; set; }
    }

    public class vyuICGetItemPricing
    {
        public int intPricingKey { get; set; }
        public int intKey { get; set; }
        public string strItemNo { get; set; }
        public string strDescription { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strUpcCode { get; set; }
        public string strLongUPCCode { get; set; }
        public int? intItemPricingId { get; set; }
        public int? intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public int? intItemUOMId { get; set; }
        public int? intUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public bool? ysnStockUnit { get; set; }
        public bool? ysnAllowPurchase { get; set; }
        public bool? ysnAllowSale { get; set; }
        public decimal? dblUnitQty { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public int? intSort { get; set; }
        public int? intDecimalPlaces { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
    }

    public class vyuICGetItemLocation
    {
        public int intItemLocationId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strDescription { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intIssueUOMId { get; set; }
        public string strIssueUOM { get; set; }
        public int? intReceiveUOMId { get; set; }
        public string strReceiveUOM { get; set; }
        public int? intFamilyId { get; set; }
        public string strFamily { get; set; }
        public int? intClassId { get; set; }
        public string strClass { get; set; }
        public int? intProductCodeId { get; set; }
        public string strPassportFuelId1 { get; set; }
        public string strPassportFuelId2 { get; set; }
        public string strPassportFuelId3 { get; set; }
        public bool? ysnTaxFlag1 { get; set; }
        public bool? ysnTaxFlag2 { get; set; }
        public bool? ysnTaxFlag3 { get; set; }
        public bool? ysnTaxFlag4 { get; set; }
        public bool? ysnPromotionalItem { get; set; }
        public int? intMixMatchId { get; set; }
        public string strPromoItemListId { get; set; }
        public bool? ysnDepositRequired { get; set; }
        public int? intDepositPLUId { get; set; }
        public string strDepositPLU { get; set; }
        public int? intBottleDepositNo { get; set; }
        public bool? ysnSaleable { get; set; }
        public bool? ysnQuantityRequired { get; set; }
        public bool? ysnScaleItem { get; set; }
        public bool? ysnFoodStampable { get; set; }
        public bool? ysnReturnable { get; set; }
        public bool? ysnPrePriced { get; set; }
        public bool? ysnOpenPricePLU { get; set; }
        public bool? ysnLinkedItem { get; set; }
        public string strVendorCategory { get; set; }
        public bool? ysnCountBySINo { get; set; }
        public string strSerialNoBegin { get; set; }
        public string strSerialNoEnd { get; set; }
        public bool? ysnIdRequiredLiquor { get; set; }
        public bool? ysnIdRequiredCigarette { get; set; }
        public int? intMinimumAge { get; set; }
        public bool? ysnApplyBlueLaw1 { get; set; }
        public bool? ysnApplyBlueLaw2 { get; set; }
        public bool? ysnCarWash { get; set; }
        public int? intItemTypeCode { get; set; }
        public string strItemTypeCode { get; set; }
        public int? intItemTypeSubCode { get; set; }
        public bool? ysnAutoCalculateFreight { get; set; }
        public int? intFreightMethodId { get; set; }
        public string strFreightTerm { get; set; }
        public decimal? dblFreightRate { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblSuggestedQty { get; set; }
        public decimal? dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public bool? ysnCountedDaily { get; set; }
        public bool? ysnLockedInventory { get; set; }
        public int? intSort { get; set; }

        public tblICItemLocation tblICItemLocation { get; set; }
        public tblSTSubcategoryRegProd tblSTSubcategoryRegProd { get; set; }
    }

    public class vyuICGetItemAccount
    {
        public int intAccountKey { get; set; }
        public int intKey { get; set; }
        public int intItemAccountId { get; set; }
        public int? intItemId { get; set; }
        public int? intAccountId { get; set; }
        public string strAccountId { get; set; }
        public int? intAccountGroupId { get; set; }
        public int? intAccountCategoryId { get; set; }
        public string strAccountGroup { get; set; }
        public string strAccountType { get; set; }
        public string strAccountCategory { get; set; }
        public int? intSort { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
    }

    public class vyuICGetItemStockUOMTotals
    {
        public int? intStorageLocationId { get; set; }
        public int intItemStockUOMId { get; set; }
        public int? intLocationId { get; set; }
        public string strUnitMeasure { get; set; }
        public int? intItemId { get; set;}
        public int? intSubLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intItemLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public decimal? dblStorageQty { get; set; }
        public decimal? dblOnHand { get; set; }
        public bool ysnStockUnit { get; set; }
        public int? intItemUOMId { get; set; }
    }

    public class vyuICGetItemStockUOM
    {
        public int intItemStockUOMId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodity { get; set; }
        public string strLotTracking { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intLotId { get; set; }
        public string strLotNumber { get; set; }
        public string strLotAlias { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblReservedQty { get; set; }
        public decimal? dblAvailableQty { get; set; }
        public decimal? dblStorageQty { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool? ysnStockUnit { get; set; }
        public decimal? dblStockUnitCost { get; set; }
        public decimal? dblLastCost { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
    }

    public class vyuICGetItemStockUOMSummary
    {
        public int intKey { get; set; }
        public int intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public decimal? dblUnitQty { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblInConsigned { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
    }

    public class vyuICGetItemStockUOMForAdjustment
    {
        public int intItemStockUOMId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public string strType { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intItemUOMId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblOnHand { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblUnitQty { get; set; }
        public bool? ysnStockUnit { get; set; }
    }

    public class vyuICGetInventoryValuation
    {
        public int intInventoryValuationKeyId { get; set; }
        public int? intInventoryTransactionId { get; set; }
        public int? intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategory { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public DateTime? dtmDate { get; set; }
        public string strTransactionType { get; set; }
        public string strTransactionForm { get; set; }
        public string strTransactionId { get; set; }
        public decimal? dblBeginningQtyBalance { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblRunningQtyBalance { get; set; }
        public decimal? dblCost { get; set; }
        public decimal? dblBeginningBalance { get; set; }
        public decimal? dblValue { get; set; }
        public decimal? dblRunningBalance { get; set; }
        public string strBatchId { get; set; }
        public string strCostingMethod { get; set; }
        public string strUOM { get; set; }
        public string strStockUOM { get; set; }
        public decimal? dblQuantityInStockUOM { get; set; }
        public decimal? dblCostInStockUOM { get; set; }
        public string strBOLNumber { get; set; }
        public string strEntity { get; set; }
        public string strLotNumber { get; set; }
        public string strAdjustedTransaction { get; set; }
    }

    public class vyuICGetInventoryValuationSummary
    {
        public int intInventoryValuationKeyId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public decimal? dblQuantity { get; set; }
        public decimal? dblValue { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblQuantityInStockUOM { get; set; }
        public string strStockUOM { get; set; }
        public string strCategoryCode { get; set; }
        public string strCommodityCode { get; set; }
        public string strInTransitLocationName { get; set; }
        public int? intLocationId { get; set; }
        public int? intInTransitLocationId { get; set; }
    }

    public class vyuSMGetCompanyLocationSearchList
    {
        public int intCompanyLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationNumber { get; set; }
        public string strLocationType { get; set; }
    }

    public class GetItemLocationVM
    {
        //Values from vyuICGetItemLocation
        public int intItemLocationId { get; set; }
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strItemDescription { get; set; }
        public int? intLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public string strVendorName { get; set; }
        public string strDescription { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public int? intIssueUOMId { get; set; }
        public string strIssueUOM { get; set; }
        public int? intReceiveUOMId { get; set; }
        public string strReceiveUOM { get; set; }
        public int? intFamilyId { get; set; }
        public string strFamily { get; set; }
        public int? intClassId { get; set; }
        public string strClass { get; set; }
        public int? intProductCodeId { get; set; }
        public string strPassportFuelId1 { get; set; }
        public string strPassportFuelId2 { get; set; }
        public string strPassportFuelId3 { get; set; }
        public bool? ysnTaxFlag1 { get; set; }
        public bool? ysnTaxFlag2 { get; set; }
        public bool? ysnTaxFlag3 { get; set; }
        public bool? ysnTaxFlag4 { get; set; }
        public bool? ysnPromotionalItem { get; set; }
        public int? intMixMatchId { get; set; }
        public string strPromoItemListId { get; set; }
        public bool? ysnDepositRequired { get; set; }
        public int? intDepositPLUId { get; set; }
        public string strDepositPLU { get; set; }
        public int? intBottleDepositNo { get; set; }
        public bool? ysnSaleable { get; set; }
        public bool? ysnQuantityRequired { get; set; }
        public bool? ysnScaleItem { get; set; }
        public bool? ysnFoodStampable { get; set; }
        public bool? ysnReturnable { get; set; }
        public bool? ysnPrePriced { get; set; }
        public bool? ysnOpenPricePLU { get; set; }
        public bool? ysnLinkedItem { get; set; }
        public string strVendorCategory { get; set; }
        public bool? ysnCountBySINo { get; set; }
        public string strSerialNoBegin { get; set; }
        public string strSerialNoEnd { get; set; }
        public bool? ysnIdRequiredLiquor { get; set; }
        public bool? ysnIdRequiredCigarette { get; set; }
        public int? intMinimumAge { get; set; }
        public bool? ysnApplyBlueLaw1 { get; set; }
        public bool? ysnApplyBlueLaw2 { get; set; }
        public bool? ysnCarWash { get; set; }
        public int? intItemTypeCode { get; set; }
        public string strItemTypeCode { get; set; }
        public int? intItemTypeSubCode { get; set; }
        public bool? ysnAutoCalculateFreight { get; set; }
        public int? intFreightMethodId { get; set; }
        public string strFreightTerm { get; set; }
        public decimal? dblFreightRate { get; set; }
        public int? intShipViaId { get; set; }
        public string strShipVia { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblSuggestedQty { get; set; }
        public decimal? dblLeadTime { get; set; }
        public string strCounted { get; set; }
        public int? intCountGroupId { get; set; }
        public string strCountGroup { get; set; }
        public bool? ysnCountedDaily { get; set; }
        public bool? ysnLockedInventory { get; set; }
        public int? intSort { get; set; }

        //Value from tblSTSubcategoryRegProd
        public string strRegProdCode { get; set; }
    }

    public class vyuICGetItemOwner
    {
        public int intItemOwnerId { get; set; }
        public int intItemId { get; set; }
        public int intOwnerId { get; set; }
        public string strName { get; set; }
        public string strCustomerNumber { get; set; }
        public string strItemNo { get; set;  }
    }

    public class vyuICItemSubLocations
    {
        public int intItemSubLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intConcurrencyId { get; set; }

    }

    public class vyuICGetItemSubLocations
    {
        public int intId { get; set; }
        public string strItemNo { get; set; }
        public int intItemId { get; set; }
        public int intLocationId { get; set; }
        public int intItemLocationId { get; set; }
        public int intSubLocationId { get; set; }
        public string strSubLocationName { get; set; }
        public int? intCountryId { get; set; }
    }

    public class vyuICStockDetail
    {
        [Key]
        public int intKey { get; set; }

        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strLotTracking { get; set; }
        public string strInventoryTracking { get; set; }
        public string strStatus { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intCategoryId { get; set; }
        public string strCategoryCode { get; set; }
        public int? intCommodityId { get; set; }
        public string strCommodityCode { get; set; }
        public string strStorageLocationName { get; set; }
        public string strSubLocationName { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intStockUOMId { get; set; }
        public string strStockUOM { get; set; }
        public string strStockUOMType { get; set; }
        public decimal? dblStockUnitQty { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblInTransitInbound { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblInTransitOutbound { get; set; }
        public decimal? dblBackOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblUnitStorage { get; set; }
        public decimal? dblConsignedPurchase { get; set; }
        public decimal? dblConsignedSale { get; set; }
        public decimal? dblUnitReserved { get; set; }
        public decimal? dblAvailable { get; set; }
        public decimal? dblExtendedCost { get; set; }
    }
}
