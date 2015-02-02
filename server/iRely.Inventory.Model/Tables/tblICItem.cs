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
        public tblICItem()
        {
            //this.tblICItemUOMs = new List<tblICItemUOM>();
            //this.tblICItemLocations = new List<tblICItemLocation>();
            //this.tblICItemPOSSLAs = new List<tblICItemPOSSLA>();
            //this.tblICItemPOSCategories = new List<tblICItemPOSCategory>();
            //this.tblICItemManufacturingUOMs = new List<tblICItemManufacturingUOM>();
            //this.tblICItemUPCs = new List<tblICItemUPC>();
            //this.tblICItemVendorXrefs = new List<tblICItemVendorXref>();
            //this.tblICItemCustomerXrefs = new List<tblICItemCustomerXref>();
            //this.tblICItemContracts = new List<tblICItemContract>();
            //this.tblICItemCertifications = new List<tblICItemCertification>();
            //this.tblICItemPricings = new List<tblICItemPricing>();
            //this.tblICItemPricingLevels = new List<tblICItemPricingLevel>();
            //this.tblICItemSpecialPricings = new List<tblICItemSpecialPricing>();
            //this.tblICItemStocks = new List<tblICItemStock>();
            //this.tblICItemAccounts = new List<tblICItemAccount>();
            //this.tblICItemNotes = new List<tblICItemNote>();
            //this.tblICItemFactories = new List<tblICItemFactory>();
            //this.tblICItemOwners = new List<tblICItemOwner>();
            //this.tblICItemKits = new List<tblICItemKit>();
            //this.tblICItemAssemblies = new List<tblICItemAssembly>();
            //this.tblICItemBundles = new List<tblICItemBundle>();
        }

        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public int? intManufacturerId { get; set; }
        public int? intBrandId { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strInventoryTracking { get; set; }
        public string strLotTracking { get; set; }
        public bool ysnRequireCustomerApproval { get; set; }
        public int? intRecipeId { get; set; }
        public bool ysnSanitationRequired { get; set; }
        public int? intLifeTime { get; set; }
        public string strLifeTimeType { get; set; }
        public int? intReceiveLife { get; set; }
        public string strGTIN { get; set; }
        public string strRotationType { get; set; }
        public int? intNMFCId { get; set; }
        public bool ysnStrictFIFO { get; set; }
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
        public int? intPatronageCategoryId { get; set; }
        public int? intTaxClassId { get; set; }
        public bool ysnStockedItem { get; set; }
        public bool ysnDyedFuel { get; set; }
        public string strBarcodePrint { get; set; }
        public bool ysnMSDSRequired { get; set; }
        public string strEPANumber { get; set; }
        public bool ysnInboundTax { get; set; }
        public bool ysnOutboundTax { get; set; }
        public bool ysnRestrictedChemical { get; set; }
        public bool ysnTankRequired { get; set; }
        public bool ysnAvailableTM { get; set; }
        public decimal? dblDefaultFull { get; set; }
        public string strFuelInspectFee { get; set; }
        public string strRINRequired { get; set; }
        public int? intRINFuelTypeId { get; set; }
        public decimal? dblDenaturantPercent { get; set; }
        public bool ysnTonnageTax { get; set; }
        public bool ysnLoadTracking { get; set; }
        public decimal? dblMixOrder { get; set; }
        public bool ysnHandAddIngredient { get; set; }
        public int? intMedicationTag { get; set; }
        public int? intIngredientTag { get; set; }
        public string strVolumeRebateGroup { get; set; }
        public int? intPhysicalItem { get; set; }
        public bool ysnExtendPickTicket { get; set; }
        public bool ysnExportEDI { get; set; }
        public bool ysnHazardMaterial { get; set; }
        public bool ysnMaterialFee { get; set; }
        public string strNACSCategory { get; set; }
        public string strWICCode { get; set; }
        public int? intAGCategory { get; set; }
        public bool ysnReceiptCommentRequired { get; set; }
        public string strCountCode { get; set; }
        public bool ysnLandedCost { get; set; }
        public string strLeadTime { get; set; }
        public bool ysnTaxable { get; set; }
        public string strKeywords { get; set; }
        public decimal? dblCaseQty { get; set; }
        public DateTime? dtmDateShip { get; set; }
        public decimal? dblTaxExempt { get; set; }
        public bool ysnDropShip { get; set; }
        public bool ysnCommisionable { get; set; }
        public bool ysnSpecialCommission { get; set; }
        public int? intCommodityId { get; set; }
        public int? intCommodityHierarchyId { get; set; }
        public decimal? dblGAShrinkFactor { get; set; }
        public int? intOriginId { get; set; }
        public int? intProductTypeId { get; set; }
        public int? intRegionId { get; set; }
        public int? intSeasonId { get; set; }
        public int? intClassVarietyId { get; set; }
        public int? intProductLineId { get; set; }
        public string strMarketValuation { get; set; }

        private string _manufacturer;
        [NotMapped]
        public string strManufacturer
        {
            get
            {
                if (string.IsNullOrEmpty(_manufacturer))
                    if (tblICManufacturer != null)
                        return tblICManufacturer.strManufacturer;
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
        private string _brand;
        [NotMapped]
        public string strBrand
        {
            get
            {
                if (string.IsNullOrEmpty(_brand))
                    if (tblICBrand != null)
                        return tblICBrand.strBrandCode;
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

        public tblICManufacturer tblICManufacturer { get; set; }
        public tblICBrand tblICBrand { get; set; }

        public ICollection<tblICItemUOM> tblICItemUOMs { get; set; }
        public ICollection<tblICItemLocation> tblICItemLocations { get; set; }

        public ICollection<tblICItemPOSSLA> tblICItemPOSSLAs { get; set; }
        public ICollection<tblICItemPOSCategory> tblICItemPOSCategories { get; set; }
        public ICollection<tblICItemManufacturingUOM> tblICItemManufacturingUOMs { get; set; }

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
        public ICollection<tblICItemAssembly> AssemblyItems { get; set; }
        public ICollection<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public ICollection<tblICInventoryReceiptItem> tblICInventoryReceiptItems { get; set; }
        public ICollection<tblICInventoryShipmentItem> tblICInventoryShipmentItems { get; set; }

        //public tblICCommodity tblICCommodity { get; set; }
        //public tblICCommodityAttribute CommodityOrigin { get; set; }
        //public tblICCommodityAttribute CommodityProductType { get; set; }
        //public tblICCommodityAttribute CommodityRegion { get; set; }
        //public tblICCommodityAttribute CommoditySeason { get; set; }
        //public tblICCommodityAttribute CommodityClassVariety { get; set; }
        //public tblICCommodityAttribute CommodityProductLine { get; set; }
        
    }

    public class ItemVM : BaseEntity
    {
        [Key]
        public int intItemId { get; set; }
        public string strItemNo { get; set; }
        public string strType { get; set; }
        public string strDescription { get; set; }
        public string strManufacturer { get; set; }
        public string strBrand { get; set; }
        public string strStatus { get; set; }
        public string strModelNo { get; set; }
        public string strTracking { get; set; }
        public string strLotTracking { get; set; }
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
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intVendorId { get; set; }
        public string strVendorId { get; set; }
        public int? intReceiveUOMId { get; set; }
        public int? intIssueUOMId { get; set; }
        public string strReceiveUOM { get; set; }
        public string strIssueUOM { get; set; }
        public int? intSubLocationId { get; set; }
        public int? intStorageLocationId { get; set; }
        public string strStorageLocationName { get; set; }
        public decimal? dblMinOrder { get; set; }
        public decimal? dblReorderPoint { get; set; }
        public int? intAllowNegativeInventory { get; set; }
        public string strAllowNegativeInventory { get; set; }
        public int? intCostingMethod { get; set; }
        public string strCostingMethod { get; set; }
        public decimal? dblUnitOnHand { get; set; }
        public decimal? dblAverageCost { get; set; }
        public decimal? dblOnOrder { get; set; }
        public decimal? dblOrderCommitted { get; set; }
        public decimal? dblBackOrder { get; set; }

        public ICollection<vyuICGetItemPricing> tblICItemPricings { get; set; }
        public ICollection<vyuICGetItemAccount> tblICItemAccounts { get; set; }
    }

    public class vyuICGetItemPricing
    {
        public int intPricingKey { get; set; }
        public int intKey { get; set; }
        public int intItemPricingId { get; set; }
        public int? intItemId { get; set; }
        public int? intLocationId { get; set; }
        public int? intItemLocationId { get; set; }
        public string strLocationName { get; set; }
        public string strLocationType { get; set; }
        public int? intItemUnitMeasureId { get; set; }
        public string strUnitMeasure { get; set; }
        public string strUnitType { get; set; }
        public bool ysnStockUnit { get; set; }
        public decimal? dblRetailPrice { get; set; }
        public decimal? dblWholesalePrice { get; set; }
        public decimal? dblLargeVolumePrice { get; set; }
        public decimal? dblAmountPercent { get; set; }
        public decimal? dblSalePrice { get; set; }
        public decimal? dblMSRPPrice { get; set; }
        public string strPricingMethod { get; set; }
        public decimal? dblLastCost { get; set; }
        public decimal? dblStandardCost { get; set; }
        public decimal? dblMovingAverageCost { get; set; }
        public decimal? dblEndMonthCost { get; set; }
        public DateTime? dtmBeginDate { get; set; }
        public DateTime? dtmEndDate { get; set; }
        public int? intSort { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
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
        public string strAccountGroup { get; set; }
        public string strAccountType { get; set; }
        public string strAccountCategory { get; set; }
        public int? intSort { get; set; }

        public vyuICGetItemStock vyuICGetItemStock { get; set; }
    }

}
