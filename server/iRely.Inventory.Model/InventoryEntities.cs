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
            : base(Security.GetCompanyName())
        {
            Database.SetInitializer<InventoryEntities>(null);
            this.Configuration.ProxyCreationEnabled = false;
        }     
        
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Configurations.Add(new vyuICLotHistoryMap());
            modelBuilder.Configurations.Add(new tblICBrandMap());
            modelBuilder.Configurations.Add(new tblICCategoryMap());
            modelBuilder.Configurations.Add(new tblICCategoryTaxMap());
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
            modelBuilder.Configurations.Add(new tblICItemSubLocationMap());
            modelBuilder.Configurations.Add(new vyuICItemSubLocationsMap());
            modelBuilder.Configurations.Add(new tblICItemCommodityCostMap());
            modelBuilder.Configurations.Add(new tblICItemNoteMap());
            modelBuilder.Configurations.Add(new tblICItemOwnerMap());
            modelBuilder.Configurations.Add(new tblICItemPOSCategoryMap());
            modelBuilder.Configurations.Add(new tblICItemPOSSLAMap());
            modelBuilder.Configurations.Add(new tblICItemPricingMap());
            modelBuilder.Configurations.Add(new tblICItemPricingLevelMap());
            modelBuilder.Configurations.Add(new tblSMCompanyLocationPricingLevelMap());
            modelBuilder.Configurations.Add(new tblICItemSpecialPricingMap());
            modelBuilder.Configurations.Add(new tblICItemStockMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionMap());
            modelBuilder.Configurations.Add(new tblICItemSubstitutionDetailMap());
            modelBuilder.Configurations.Add(new tblICItemUOMMap());
            modelBuilder.Configurations.Add(new tblICItemUPCMap());
            modelBuilder.Configurations.Add(new tblICItemVendorXrefMap());
            modelBuilder.Configurations.Add(new tblSMLineOfBusinessMap());
            modelBuilder.Configurations.Add(new tblICLotStatusMap());
            modelBuilder.Configurations.Add(new tblICManufacturerMap());
            modelBuilder.Configurations.Add(new tblICM2MComputationMap());
            modelBuilder.Configurations.Add(new vyuICItemUOMMap());

            modelBuilder.Configurations.Add(new tblICMaterialNMFCMap());    
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
            modelBuilder.Configurations.Add(new vyuICItemLotMap());
            modelBuilder.Configurations.Add(new tblICParentLotMap());

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
            modelBuilder.Configurations.Add(new vyuICShipmentInvoiceMap());

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
            modelBuilder.Configurations.Add(new tblGLAccountGroupMap());
            modelBuilder.Configurations.Add(new tblGLAccountCategoryMap());
            modelBuilder.Configurations.Add(new vyuAPVendorMap());
            modelBuilder.Configurations.Add(new tblARCustomerMap());
            modelBuilder.Configurations.Add(new tblSMCountryMap());
            modelBuilder.Configurations.Add(new tblSMCurrencyMap());
            modelBuilder.Configurations.Add(new tblSMCompanyLocationSubLocationMap());
            modelBuilder.Configurations.Add(new tblSMTaxCodeMap());
            modelBuilder.Configurations.Add(new tblSMPurchasingGroupMap());

            modelBuilder.Configurations.Add(new tblSTPaidOutMap());
            modelBuilder.Configurations.Add(new tblSTStoreMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryMap());
            modelBuilder.Configurations.Add(new tblSTSubcategoryRegProdMap());

            modelBuilder.Configurations.Add(new tblGRStorageTypeMap());
            modelBuilder.Configurations.Add(new tblSTPromotionSalesListMap());

            modelBuilder.Configurations.Add(new tblPATPatronageCategoryMap());

            modelBuilder.Configurations.Add(new vyuICGetInventoryTransferMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryTransferDetailMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockSummaryMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockSummaryByLotMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMTotalsMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMSummaryMap());
            modelBuilder.Configurations.Add(new vyuICGetItemStockUOMForAdjustmentMap());
            modelBuilder.Configurations.Add(new vyuICGetItemAccountMap());
            modelBuilder.Configurations.Add(new vyuICGetItemPricingMap());
            modelBuilder.Configurations.Add(new vyuICGetItemLocationMap());
            modelBuilder.Configurations.Add(new vyuSMGetCompanyLocationSearchListMap());

            modelBuilder.Configurations.Add(new tblICCompanyPreferenceMap());
            modelBuilder.Configurations.Add(new tblSMStartingNumberMap());
           // modelBuilder.Configurations.Add(new tblMFQAPropertyMap());

            modelBuilder.Configurations.Add(new vyuICGetInventoryValuationMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryValuationSummaryMap());
            modelBuilder.Configurations.Add(new vyuICGetAssemblyItemMap());
            modelBuilder.Configurations.Add(new vyuICGetCompactItemMap());
            modelBuilder.Configurations.Add(new vyuICGetItemCommodityMap());
            modelBuilder.Configurations.Add(new vyuICGetOtherChargesMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryAdjustmentMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryAdjustmentDetailMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentItemMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentItemLotMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemMap());            
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemTaxMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemLotMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemLot2Map());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptChargeMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptVoucherMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptItemViewMap());
            modelBuilder.Configurations.Add(new vyuICGetItemUOMMap());

            modelBuilder.Configurations.Add(new vyuICInventoryReceiptLookUpMap());
            modelBuilder.Configurations.Add(new vyuICInventoryReceiptItemLookUpMap());            
            
            modelBuilder.Configurations.Add(new vyuICGetInventoryShipmentChargeMap());
            modelBuilder.Configurations.Add(new vyuICGetPackedUOMMap());
            modelBuilder.Configurations.Add(new vyuICGetUOMConversionMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageLocationMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageBinsMap());
            modelBuilder.Configurations.Add(new vyuICGetSubLocationBinsMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageBinDetailsMap());
            modelBuilder.Configurations.Add(new vyuICGetSubLocationBinDetailsMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageBinMeasurementReadingMap());

            modelBuilder.Configurations.Add(new vyuICGetPostedLotMap());
            modelBuilder.Configurations.Add(new vyuICGetItemFactoryManufacturingCellMap());
            modelBuilder.Configurations.Add(new vyuICGetCategoryTaxMap());

            modelBuilder.Configurations.Add(new vyuICGetReceiptAddOrderMap());
            modelBuilder.Configurations.Add(new vyuICGetReceiptAddPurchaseOrderMap());
            modelBuilder.Configurations.Add(new vyuICGetReceiptAddTransferOrderMap());
            modelBuilder.Configurations.Add(new vyuICGetReceiptAddPurchaseContractMap());
            modelBuilder.Configurations.Add(new vyuICGetReceiptAddLGInboundShipmentMap());

            modelBuilder.Configurations.Add(new vyuICGetShipmentAddOrderMap());
            modelBuilder.Configurations.Add(new vyuICGetShipmentAddSalesOrderMap());
            modelBuilder.Configurations.Add(new vyuICGetShipmentAddSalesContractMap());
            modelBuilder.Configurations.Add(new vyuICGetShipmentAddSalesContractPickLotMap());

            modelBuilder.Configurations.Add(new tblICStorageMeasurementReadingMap());
            modelBuilder.Configurations.Add(new tblICStorageMeasurementReadingConversionMap());
            modelBuilder.Configurations.Add(new vyuICGetStorageMeasurementReadingConversionMap());

            modelBuilder.Configurations.Add(new tblICItemMotorFuelTaxMap());
            modelBuilder.Configurations.Add(new vyuICGetItemMotorFuelTaxMap());

            modelBuilder.Configurations.Add(new vyuICGetBundleItemMap());
            modelBuilder.Configurations.Add(new tblICInventoryCountMap());
            modelBuilder.Configurations.Add(new tblICInventoryCountDetailMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryCountMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryCountDetailMap());
            modelBuilder.Configurations.Add(new vyuICGetCountSheetMap());

            modelBuilder.Configurations.Add(new tblICInventoryReceiptChargeTaxMap());
            modelBuilder.Configurations.Add(new vyuICGetInventoryReceiptChargeTaxMap());

            modelBuilder.Configurations.Add(new vyuICGetChargeTaxDetailsMap());
            modelBuilder.Configurations.Add(new vyuICGetItemOwnerMap());
            modelBuilder.Configurations.Add(new vyuICGetItemSubLocationsMap());
            modelBuilder.Configurations.Add(new vyuICStockDetailMap());
        }
    }
}
