using iRely.Common;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Model
{
    public partial class InventoryEntities : DbContext
    {
        static InventoryEntities()
        {
            Database.SetInitializer<InventoryEntities>(null);
        }

        public InventoryEntities()
            : base(iRely.Common.Security.GetCompanyName())
        {
            Database.SetInitializer<InventoryEntities>(null);
            this.Configuration.ProxyCreationEnabled = false;
        }
        
        public DbSet<tblICBrand> tblICBrands { get; set; }
        public DbSet<tblICBuildAssembly> tblICBuildAssemblys { get; set; }
        public DbSet<tblICBuildAssemblyDetail> tblICBuildAssemblyDetails { get; set; }
        public DbSet<tblICCategory> tblICCategorys { get; set; }
        public DbSet<tblICCategoryAccount> tblICCategoryAccounts { get; set; }
        public DbSet<tblICCategoryLocation> tblICCategoryLocations { get; set; }
        public DbSet<tblICCategoryUOM> tblICCategoryUOMs { get; set; }
        public DbSet<tblICCategoryVendor> tblICCategoryVendors { get; set; }
        public DbSet<tblICCertification> tblICCertifications { get; set; }
        public DbSet<tblICCertificationCommodity> tblICCertificationCommoditys { get; set; }
        public DbSet<tblICCommodity> tblICCommoditys { get; set; }
        public DbSet<tblICCommodityAccount> tblICCommodityAccounts { get; set; }
        public DbSet<tblICCommodityAttribute> tblICCommodityAttributes { get; set; }
        public DbSet<tblICCommodityGroup> tblICCommodityGroups { get; set; }
        public DbSet<tblICCommodityUnitMeasure> tblICCommodityUnitMeasures { get; set; }
        public DbSet<tblICContainer> tblICContainers { get; set; }
        public DbSet<tblICContainerType> tblICContainerTypes { get; set; }
        public DbSet<tblICCountGroup> tblICCountGroups { get; set; }
        public DbSet<tblICDocument> tblICDocuments { get; set; }
        public DbSet<tblICEquipmentLength> tblICEquipmentLengths { get; set; }
        public DbSet<tblICFuelTaxClass> tblICFuelTaxClasss { get; set; }
        public DbSet<tblICFuelTaxClassProductCode> tblICFuelTaxClassProductCodes { get; set; }
        public DbSet<tblICFuelType> tblICFuelTypes { get; set; }
        public DbSet<tblICItem> tblICItems { get; set; }
        public DbSet<tblICItemAccount> tblICItemAccounts { get; set; }
        public DbSet<tblICItemAssembly> tblICItemAssemblys { get; set; }
        public DbSet<tblICItemBundle> tblICItemBundles { get; set; }
        public DbSet<tblICItemCertification> tblICItemCertifications { get; set; }
        public DbSet<tblICItemCommodityCost> tblICItemCommodityCosts { get; set; }
        public DbSet<tblICItemContract> tblICItemContracts { get; set; }
        public DbSet<tblICItemContractDocument> tblICItemContractDocuments { get; set; }
        public DbSet<tblICItemCustomerXref> tblICItemCustomerXrefs { get; set; }
        public DbSet<tblICItemFactory> tblICItemFactorys { get; set; }
        public DbSet<tblICItemFactoryManufacturingCell> tblICItemFactoryManufacturingCells { get; set; }
        public DbSet<tblICItemKit> tblICItemKits { get; set; }
        public DbSet<tblICItemKitDetail> tblICItemKitDetails { get; set; }
        public DbSet<tblICItemLocation> tblICItemLocations { get; set; }
        public DbSet<tblICItemNote> tblICItemNotes { get; set; }
        public DbSet<tblICItemOwner> tblICItemOwners { get; set; }
        public DbSet<tblICItemPOSCategory> tblICItemPOSCategorys { get; set; }
        public DbSet<tblICItemPOSSLA> tblICItemPOSSLAs { get; set; }
        public DbSet<tblICItemPricing> tblICItemPricings { get; set; }
        public DbSet<tblICItemPricingLevel> tblICItemPricingLevels { get; set; }
        public DbSet<tblICItemSpecialPricing> tblICItemSpecialPricings { get; set; }
        public DbSet<tblICItemStock> tblICItemStocks { get; set; }
        public DbSet<tblICItemSubstitution> tblICItemSubstitutions { get; set; }
        public DbSet<tblICItemSubstitutionDetail> tblICItemSubstitutionDetails { get; set; }
        public DbSet<tblICItemUOM> tblICItemUOMs { get; set; }
        public DbSet<tblICItemUPC> tblICItemUPCs { get; set; }
        public DbSet<tblICItemVendorXref> tblICItemVendorXrefs { get; set; }
        public DbSet<tblICLineOfBusiness> tblICLineOfBusinesss { get; set; }
        public DbSet<tblICLot> tblICLots { get; set; }
        public DbSet<tblICLotStatus> tblICLotStatuss { get; set; }
        public DbSet<tblICManufacturer> tblICManufacturers { get; set; }
        public DbSet<tblICManufacturingCell> tblICManufacturingCells { get; set; }
        public DbSet<tblICMaterialNMFC> tblICMaterialNMFCs { get; set; }
        public DbSet<tblICMeasurement> tblICMeasurements { get; set; }
        public DbSet<tblICPatronageCategory> tblICPatronageCategorys { get; set; }
        public DbSet<tblICReadingPoint> tblICReadingPoints { get; set; }
        public DbSet<tblICReasonCode> tblICReasonCodes { get; set; }
        public DbSet<tblICReasonCodeWorkCenter> tblICReasonCodeWorkCenters { get; set; }
        public DbSet<tblICRestriction> tblICRestrictions { get; set; }
        public DbSet<tblICRinFeedStock> tblICRinFeedStocks { get; set; }
        public DbSet<tblICRinFeedStockUOM> tblICRinFeedStockUOMs { get; set; }
        public DbSet<tblICRinFuel> tblICRinFuels { get; set; }
        public DbSet<tblICRinFuelCategory> tblICRinFuelCategorys { get; set; }
        public DbSet<tblICRinProcess> tblICRinProcesss { get; set; }
        public DbSet<tblICSku> tblICSkus { get; set; }
        public DbSet<tblICStatus> tblICStatuss { get; set; }
        public DbSet<tblICStockReservation> tblICStockReservations { get; set; }
        public DbSet<tblICStorageLocation> tblICStorageLocations { get; set; }
        public DbSet<tblICStorageLocationCategory> tblICStorageLocationCategorys { get; set; }
        public DbSet<tblICStorageLocationContainer> tblICStorageLocationContainers { get; set; }
        public DbSet<tblICStorageLocationMeasurement> tblICStorageLocationMeasurements { get; set; }
        public DbSet<tblICStorageLocationSku> tblICStorageLocationSkus { get; set; }
        public DbSet<tblICStorageUnitType> tblICStorageUnitTypes { get; set; }
        public DbSet<tblICTag> tblICTags { get; set; }
        public DbSet<tblICUnitMeasure> tblICUnitMeasures { get; set; }
        public DbSet<tblICUnitMeasureConversion> tblICUnitMeasureConversions { get; set; }

        public DbSet<vyuICGetInventoryTransferDetail> vyuICGetInventoryTransferDetails { get; set; }
        public DbSet<vyuICGetInventoryReceiptItem> vyuICGetInventoryReceiptItems { get; set; }
        public DbSet<vyuICGetInventoryShipmentItem> vyuICGetInventoryShipmentItems { get; set; }
        public DbSet<vyuICGetItemStock> vyuICGetItemStocks { get; set; }
        public DbSet<vyuICGetItemStockUOM> vyuICGetItemStockUOMs { get; set; }
        public DbSet<vyuICGetItemStockUOMForAdjustment> vyuICGetItemStockUOMForAdjustment { get; set; }
        public DbSet<vyuICGetItemAccount> vyuICGetItemAccounts { get; set; }
        public DbSet<vyuICGetItemPricing> vyuICGetItemPricings { get; set; }
        public DbSet<vyuICGetPackedUOM> vyuICGetPackedUOMs { get; set; }
        public DbSet<vyuICGetUOMConversion> vyuICGetUOMConversions { get; set; }
        public DbSet<vyuICGetStorageLocation> vyuICGetStorageLocations { get; set; }
        public DbSet<vyuICGetPostedLot> vyuICGetPostedLots { get; set; }

        public DbSet<tblEntityLocation> tblEntityLocations { get; set; }
        public DbSet<tblSMCompanyLocation> tblSMCompanyLocations { get; set; }
        public DbSet<tblSMCountry> tblSMCountries { get; set; }
        public DbSet<tblSMCurrency> tblSMCurrencies { get; set; }
        public DbSet<tblSMStartingNumber> tblSMStartingNumbers { get; set; }
        public DbSet<tblSMFreightTerm> tblSMFreightTerms { get; set; }
        public DbSet<tblSMCompanyLocationSubLocation> tblSMCompanyLocationSubLocations { get; set; }
        public DbSet<tblSMTaxCode> tblSMTaxCodes { get; set; }

        public DbSet<tblGLAccount> tblGLAccounts { get; set; }
        public DbSet<tblGLAccountCategory> tblGLAccountCategories { get; set; }

        public DbSet<tblARCustomer> tblARCustomers { get; set; }
        public DbSet<vyuAPVendor> vyuAPVendors { get; set; }
        
        public DbSet<tblSTPaidOut> tblSTPaidOut { get; set; }
        public DbSet<tblSTStore> tblSTStore { get; set; }
        public DbSet<tblSTSubcategory> tblSTSubcategories { get; set; }
        public DbSet<tblSTSubcategoryRegProd> tblSTSubcategoryRegProds { get; set; }
        public DbSet<tblSTPromotionSalesList> tblSTPromotionSalesLists { get; set; }

        public DbSet<tblGRStorageType> tblGRStorageTypes { get; set; }

        public DbSet<tblMFQAProperty> tblMFQAProperties { get; set; }
        
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Configurations.Add(new tblICBrandMap());
            modelBuilder.Configurations.Add(new tblICCategoryMap());
            modelBuilder.Configurations.Add(new tblICCategoryAccountMap());
            modelBuilder.Configurations.Add(new tblICCategoryLocationMap());
            modelBuilder.Configurations.Add(new tblICCategoryVendorMap());
            modelBuilder.Configurations.Add(new tblICCategoryUOMMap());
            modelBuilder.Configurations.Add(new tblICCertificationMap());
            modelBuilder.Configurations.Add(new tblICCertificationCommodityMap());
            modelBuilder.Configurations.Add(new tblICCommodityMap());
            modelBuilder.Configurations.Add(new tblICCommodityAccountMap());
            modelBuilder.Configurations.Add(new tblICCommodityAttributeMap());
            modelBuilder.Configurations.Add(new tblICCommodityGroupMap());
            modelBuilder.Configurations.Add(new tblICCommodityUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICCountGroupMap());
            modelBuilder.Configurations.Add(new tblICDocumentMap());
            modelBuilder.Configurations.Add(new tblICFuelTaxClassMap());
            modelBuilder.Configurations.Add(new tblICFuelTaxClassProductCodeMap());
            modelBuilder.Configurations.Add(new tblICFuelTypeMap());
            modelBuilder.Configurations.Add(new tblICItemMap());
            modelBuilder.Configurations.Add(new tblICItemAccountMap());
            modelBuilder.Configurations.Add(new tblICItemAssemblyMap());
            modelBuilder.Configurations.Add(new tblICItemBundleMap());
            modelBuilder.Configurations.Add(new tblICItemCertificationMap());
            modelBuilder.Configurations.Add(new tblICItemContractMap());
            modelBuilder.Configurations.Add(new tblICItemContractDocumentMap());
            modelBuilder.Configurations.Add(new tblICItemCustomerXrefMap());
            modelBuilder.Configurations.Add(new tblICItemFactoryMap());
            modelBuilder.Configurations.Add(new tblICItemFactoryManufacturingCellMap());
            modelBuilder.Configurations.Add(new tblICItemKitMap());
            modelBuilder.Configurations.Add(new tblICItemKitDetailMap());
            modelBuilder.Configurations.Add(new tblICItemLocationMap());
            modelBuilder.Configurations.Add(new tblICItemCommodityCostMap());
            modelBuilder.Configurations.Add(new tblICItemNoteMap());
            modelBuilder.Configurations.Add(new tblICItemOwnerMap());
            modelBuilder.Configurations.Add(new tblICItemPOSCategoryMap());
            modelBuilder.Configurations.Add(new tblICItemPOSSLAMap());
            modelBuilder.Configurations.Add(new tblICItemPricingMap());
            modelBuilder.Configurations.Add(new tblICItemPricingLevelMap());
            modelBuilder.Configurations.Add(new tblICItemSpecialPricingMap());
            modelBuilder.Configurations.Add(new tblICItemStockMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionDetailMap());
            modelBuilder.Configurations.Add(new tblICItemUOMMap());
            modelBuilder.Configurations.Add(new tblICItemUPCMap());
            modelBuilder.Configurations.Add(new tblICItemVendorXrefMap());
            modelBuilder.Configurations.Add(new tblICLineOfBusinessMap());
            modelBuilder.Configurations.Add(new tblICLotStatusMap());
            modelBuilder.Configurations.Add(new tblICManufacturerMap());
            modelBuilder.Configurations.Add(new tblICManufacturingCellMap());
            modelBuilder.Configurations.Add(new tblICMaterialNMFCMap());
            modelBuilder.Configurations.Add(new tblICPatronageCategoryMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeMap());
            modelBuilder.Configurations.Add(new tblICReasonCodeWorkCenterMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockMap());
            modelBuilder.Configurations.Add(new tblICRinFeedStockUOMMap());
            modelBuilder.Configurations.Add(new tblICRinFuelMap());
            modelBuilder.Configurations.Add(new tblICRinFuelCategoryMap());
            modelBuilder.Configurations.Add(new tblICRinProcessMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationCategoryMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationMeasurementMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationSkuMap());
            modelBuilder.Configurations.Add(new tblICStorageLocationContainerMap());
            modelBuilder.Configurations.Add(new tblICStorageUnitTypeMap());
            modelBuilder.Configurations.Add(new tblICTagMap());
            modelBuilder.Configurations.Add(new tblICUnitMeasureMap());
            modelBuilder.Configurations.Add(new tblICUnitMeasureConversionMap());
            modelBuilder.Configurations.Add(new tblICLotMap());

            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityClassVariant>(p => p.Requires("strType").HasValue("Class"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityGrade>(p => p.Requires("strType").HasValue("Grade"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityOrigin>(p => p.Requires("strType").HasValue("Origin"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityProductType>(p => p.Requires("strType").HasValue("ProductType"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommodityRegion>(p => p.Requires("strType").HasValue("Region"));
            modelBuilder.Entity<tblICCommodityAttribute>().Map<tblICCommoditySeason>(p => p.Requires("strType").HasValue("Season"));

            modelBuilder.Configurations.Add(new tblICCommodityClassVariantMap());
            modelBuilder.Configurations.Add(new tblICCommodityGradeMap());
            modelBuilder.Configurations.Add(new tblICCommodityOriginMap());
            modelBuilder.Configurations.Add(new tblICCommodityProductLineMap());
            modelBuilder.Configurations.Add(new tblICCommodityProductTypeMap());
            modelBuilder.Configurations.Add(new tblICCommodityRegionMap());
            modelBuilder.Configurations.Add(new tblICCommoditySeasonMap());

            modelBuilder.Configurations.Add(new tblICContainerMap());
            modelBuilder.Configurations.Add(new tblICContainerTypeMap());
            modelBuilder.Configurations.Add(new tblICMeasurementMap());
            modelBuilder.Configurations.Add(new tblICReadingPointMap());
            modelBuilder.Configurations.Add(new tblICRestrictionMap());
            modelBuilder.Configurations.Add(new tblICSkuMap());
            modelBuilder.Configurations.Add(new tblICEquipmentLengthMap());

            modelBuilder.Configurations.Add(new tblICInventoryReceiptMap());
            modelBuilder.Configurations.Add(new tblICInventoryReceiptInspectionMap());
            modelBuilder.Configurations.Add(new tblICInventoryReceiptItemLotMap());
            modelBuilder.Configurations.Add(new tblICInventoryReceiptItemMap());
            modelBuilder.Configurations.Add(new tblICInventoryReceiptChargeMap());
            modelBuilder.Configurations.Add(new tblICInventoryReceiptItemTaxMap());

            modelBuilder.Configurations.Add(new tblICInventoryShipmentMap());
            modelBuilder.Configurations.Add(new tblICInventoryShipmentItemMap());
            modelBuilder.Configurations.Add(new tblICInventoryShipmentChargeMap());
            modelBuilder.Configurations.Add(new tblICInventoryShipmentItemLotMap());

            modelBuilder.Configurations.Add(new tblICInventoryAdjustmentMap());
            modelBuilder.Configurations.Add(new tblICInventoryAdjustmentDetailMap());

            modelBuilder.Configurations.Add(new tblICInventoryTransferMap());
            modelBuilder.Configurations.Add(new tblICInventoryTransferDetailMap());

            modelBuilder.Configurations.Add(new tblICBuildAssemblyMap());
            modelBuilder.Configurations.Add(new tblICBuildAssemblyDetailMap());

            modelBuilder.Configurations.Add(new tblICStockReservationMap());
            modelBuilder.Configurations.Add(new tblICStatusMap());

            modelBuilder.Configurations.Add(new tblSMCompanyLocationMap());
            modelBuilder.Configurations.Add(new tblGLAccountMap());
            modelBuilder.Configurations.Add(new tblGLAccountCategoryMap());
            modelBuilder.Configurations.Add(new vyuAPVendorMap());
            modelBuilder.Configurations.Add(new tblARCustomerMap());
            modelBuilder.Configurations.Add(new tblSMCountryMap());
            modelBuilder.Configurations.Add(new tblSMCurrencyMap());
            modelBuilder.Configurations.Add(new tblSMCompanyLocationSubLocationMap());
            modelBuilder.Configurations.Add(new tblSMTaxCodeMap());
            modelBuilder.Configurations.Add(new tblEntityLocationMap());

            modelBuilder.Configurations.Add(new tblSTPaidOutMap());
            modelBuilder.Configurations.Add(new tblSTStoreMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryRegProdMap());

            modelBuilder.Configurations.Add(new tblGRStorageTypeMap());
            modelBuilder.Configurations.Add(new tblSTPromotionSalesListMap());

            modelBuilder.Configurations.Add(new vyuICGetInventoryTransferDetailMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMForAdjustmentMap());
            modelBuilder.Configurations.Add(new vyuICGetItemAccountMap());
            modelBuilder.Configurations.Add(new vyuICGetItemPricingMap());

            modelBuilder.Configurations.Add(new tblICCompanyPreferenceMap());
            modelBuilder.Configurations.Add(new tblSMStartingNumberMap());
            modelBuilder.Configurations.Add(new tblSMFreightTermMap());
            modelBuilder.Configurations.Add(new tblMFQAPropertyMap());

            modelBuilder.Configurations.Add(new vyuICGetAssemblyItemMap());
            modelBuilder.Configurations.Add(new vyuICGetCompactItemMap());
            modelBuilder.Configurations.Add(new vyuICGetItemCommodityMap());
            modelBuilder.Configurations.Add(new vyuICGetOtherChargesMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentItemMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemLotMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptChargeMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentChargeMap());
            modelBuilder.Configurations.Add(new vyuICGetPackedUOMMap());
            modelBuilder.Configurations.Add(new vyuICGetUOMConversionMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageLocationMap());
            modelBuilder.Configurations.Add(new vyuICGetPostedLotMap());	
        }
    }
}
