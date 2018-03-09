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
        public tblICItem() : base()
        {
            tblICItemBundles = new List<tblICItemBundle>();
        }

        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strShortName { get; set; }
        public string strType { get; set; }
        public string strBundleType { get; set; }
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
        public int? intHazmatTag { get; set; }
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
        public bool? ysnLotWeightsRequired { get; set; }


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
                    if (strType == "Comment")
                        return "Comment";
                    else if (vyuICGetCompactItem != null)
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

        private string _Grade;
        [NotMapped]
        public string strGrade
        {
            get
            {
                if (string.IsNullOrEmpty(_Grade))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strGrade;
                    else
                        return null;
                else
                    return _Grade;
            }
            set
            {
                _Grade = value;
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

        private string _materialPackUOM;
        [NotMapped]
        public string strMaterialPackUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_materialPackUOM))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strMaterialPackUOM;
                    else
                        return null;
                else
                    return _materialPackUOM;
            }
            set
            {
                _materialPackUOM = value;
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

        private string _hazmatTag;

        [NotMapped]
        public string strHazmatTag
        {
            get
            {
                if (string.IsNullOrEmpty(_hazmatTag))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strHazmatTag;
                    else
                        return null;
                else
                    return _hazmatTag;
            }
            set
            {
                _hazmatTag = value;
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

        private string _costUOM;

        [NotMapped]
        public string strCostUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_costUOM))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strCostUOM;
                    else
                        return null;
                else
                    return _costUOM;
            }
            set
            {
                _costUOM = value;
            }
        }

        private string _dimensionUOM;

        [NotMapped]
        public string strDimensionUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_dimensionUOM))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strDimensionUOM;
                    else
                        return null;
                else
                    return _dimensionUOM;
            }
            set
            {
                _dimensionUOM = value;
            }
        }

        private string _weightUOM;

        [NotMapped]
        public string strWeightUOM
        {
            get
            {
                if (string.IsNullOrEmpty(_weightUOM))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strWeightUOM;
                    else
                        return null;
                else
                    return _weightUOM;
            }
            set
            {
                _weightUOM = value;
            }
        }

        private string _secondaryStatus;

        [NotMapped]
        public string strSecondaryStatus
        {
            get
            {
                if (string.IsNullOrEmpty(_secondaryStatus))
                    if (vyuICGetCompactItem != null)
                        return vyuICGetCompactItem.strSecondaryStatus;
                    else
                        return null;
                else
                    return _secondaryStatus;
            }
            set
            {
                _secondaryStatus = value;
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
        public ICollection<vyuICGetItemStock> vyuICGetItemStock { get; set; }
        public ICollection<tblICInventoryTransferDetail> tblICInventoryTransferDetails { get; set; }
        public ICollection<tblICItemLicense> tblICItemLicenses { get; set; }
        public ICollection<tblICItemAddOn> tblICItemAddOns { get; set; }
        public ICollection<tblICItemAddOn> AddOnItems { get; set; }
        public ICollection<tblICItemSubstitute> tblICItemSubstitutes { get; set; }
        public ICollection<tblICItemSubstitute> SubstituteItems { get; set; }

    }
}
