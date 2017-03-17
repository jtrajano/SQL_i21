// Karma configuration
// Generated on Thu Aug 18 2016 11:21:34 GMT+0800 (China Standard Time)

var extJs = [
    {pattern: '../resources/extjs/ext-6.0.2/build/ext-all.js', watched: false},
    {pattern: '../resources/extjs/ext-6.0.2/build/packages/charts/modern/charts.js', watched: false},
    //{pattern: 'app.js', watched: false },

    // load the override for Ext.data.Connection.
    {pattern: '../resources/test/override/Ext.data.Connection.js', watched: false},

     {pattern: '../GlobalComponentEngine/iRely/BaseEntity.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityCredential.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityToContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityLocation.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityNote.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/Entity.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/model/EntityContact.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Functions.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/preference/Manager.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Messages.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Configuration.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/Exporter.js', watched: false},
     {pattern: '../GlobalComponentEngine/iRely/writer/JsonBatch.js', watched: false},

     // Load the application dependencies, similar on how SM did it.
     {pattern: '../SystemManager/app/controller/UtilityManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/PreferenceManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/ModuleManager.js', watched: false},
     {pattern: '../SystemManager/app/controller/Module.js', watched: false},
     {pattern: '../SystemManager/app/model/*.js', watched: false},
     {pattern: '../SystemManager/app/store/*.js', watched: false},
     {pattern: '../SystemManager/app/data/validator/*.js', watched: false},

     {pattern: '../resources/js/deft/deft.js', watched: false},
     {pattern: '../resources/js/filesaver/filesaver.js', watched: false},
     {pattern: '../resources/js/ux/moment/moment-min.js', watched: false},
     {pattern: '../resources/js/ux/async.js', watched: false},

    // Load Base 64 js
    {pattern: '../resources/js/fn/Base64.js', watched: false},
    {pattern: 'app/lib/numeral.js', watched: true },
    {pattern: 'app/ux/**/*.js', watched: true },
];
var inventoryFiles = [{
    "pattern": "app/model/ItemUPC.js"
}, {
    "pattern": "app/model/StockReservation.js"
}, {
    "pattern": "app/model/AdjustmentDetail.js"
}, {
    "pattern": "app/model/AdjustmentNote.js"
}, {
    "pattern": "app/model/Adjustment.js"
}, {
    "pattern": "app/store/Adjustment.js"
}, {
    "pattern": "app/model/Brand.js"
}, {
    "pattern": "app/store/Brand.js"
}, {
    "pattern": "app/model/BundleComponent.js"
}, {
    "pattern": "app/store/BufferedBundleComponent.js"
}, {
    "pattern": "app/model/CategoryAccount.js"
}, {
    "pattern": "app/store/BufferedCategoryAccount.js"
}, {
    "pattern": "app/model/CategoryVendor.js"
}, {
    "pattern": "app/store/BufferedCategoryVendor.js"
}, {
    "pattern": "app/model/CommodityUnitMeasure.js"
}, {
    "pattern": "app/store/BufferedCommodityUnitMeasure.js"
}, {
    "pattern": "app/model/Container.js"
}, {
    "pattern": "app/store/BufferedContainer.js"
}, {
    "pattern": "app/model/ContainerType.js"
}, {
    "pattern": "app/store/BufferedContainerType.js"
}, {
    "pattern": "app/model/FuelType.js"
}, {
    "pattern": "app/store/BufferedFuelType.js"
}, {
    "pattern": "app/model/InventoryValuation.js"
}, {
    "pattern": "app/store/BufferedInventoryValuation.js"
}, {
    "pattern": "app/model/CompactItem.js"
}, {
    "pattern": "app/store/BufferedItemCommodity.js"
}, {
    "pattern": "app/model/CompactItemFactory.js"
}, {
    "pattern": "app/store/BufferedItemFactory.js"
}, {
    "pattern": "app/model/CompactItemFactoryManufacturingCell.js"
}, {
    "pattern": "app/store/BufferedItemFactoryManufacturingCell.js"
}, {
    "pattern": "app/model/ItemStockSummary.js"
}, {
    "pattern": "app/store/BufferedItemStockSummary.js"
}, {
    "pattern": "app/model/ManufacturingCellPackType.js"
}, {
    "pattern": "app/model/ManufacturingCell.js"
}, {
    "pattern": "app/store/BufferedManufacturingCell.js"
}, {
    "pattern": "app/model/MaterialNMFC.js"
}, {
    "pattern": "app/store/BufferedMaterialNMFC.js"
}, {
    "pattern": "app/model/Sku.js"
}, {
    "pattern": "app/store/BufferedSku.js"
}, {
    "pattern": "app/model/BuildAssemblyDetail.js"
}, {
    "pattern": "app/model/BuildAssembly.js"
}, {
    "pattern": "app/store/BuildAssembly.js"
}, {
    "pattern": "app/model/CategoryLocation.js"
}, {
    "pattern": "app/model/CategoryTax.js"
}, {
    "pattern": "app/model/CategoryUOM.js"
}, {
    "pattern": "app/model/Category.js"
}, {
    "pattern": "app/store/Category.js"
}, {
    "pattern": "app/store/CategoryLocation.js"
}, {
    "pattern": "app/model/CertificationCommodity.js"
}, {
    "pattern": "app/model/Certification.js"
}, {
    "pattern": "app/store/Certification.js"
}, {
    "pattern": "app/model/CommodityAccount.js"
}, {
    "pattern": "app/model/CommodityClass.js"
}, {
    "pattern": "app/model/CommodityGrade.js"
}, {
    "pattern": "app/model/CommodityOrigin.js"
}, {
    "pattern": "app/model/CommodityProductLine.js"
}, {
    "pattern": "app/model/CommodityProductType.js"
}, {
    "pattern": "app/model/CommodityRegion.js"
}, {
    "pattern": "app/model/CommoditySeason.js"
}, {
    "pattern": "app/model/Commodity.js"
}, {
    "pattern": "app/store/Commodity.js"
}, {
    "pattern": "app/model/CommodityAttribute.js"
}, {
    "pattern": "app/store/CommodityAttribute.js"
}, {
    "pattern": "app/store/CompactItem.js"
}, {
    "pattern": "app/model/CompanyPreference.js"
}, {
    "pattern": "app/store/CompanyPreference.js"
}, {
    "pattern": "app/model/CountGroup.js"
}, {
    "pattern": "app/store/CountGroup.js"
}, {
    "pattern": "app/model/Document.js"
}, {
    "pattern": "app/store/Document.js"
}, {
    "pattern": "app/model/FeedStockCode.js"
}, {
    "pattern": "app/store/FeedStockCode.js"
}, {
    "pattern": "app/model/FeedStockUOM.js"
}, {
    "pattern": "app/store/FeedStockUOM.js"
}, {
    "pattern": "app/model/FuelCategory.js"
}, {
    "pattern": "app/store/FuelCategory.js"
}, {
    "pattern": "app/model/FuelCode.js"
}, {
    "pattern": "app/store/FuelCode.js"
}, {
    "pattern": "app/model/FuelTaxClassProductCode.js"
}, {
    "pattern": "app/model/FuelTaxClass.js"
}, {
    "pattern": "app/store/FuelTaxClass.js"
}, {
    "pattern": "app/store/FuelType.js"
}, {
    "pattern": "app/model/InventoryCountDetail.js"
}, {
    "pattern": "app/model/InventoryCount.js"
}, {
    "pattern": "app/store/InventoryCount.js"
}, {
    "pattern": "app/model/InventoryTag.js"
}, {
    "pattern": "app/store/InventoryTag.js"
}, {
    "pattern": "app/model/ItemLocation.js"
}, {
    "pattern": "app/store/ItemLocation.js"
}, {
    "pattern": "app/model/ItemPricing.js"
}, {
    "pattern": "app/store/ItemPricing.js"
}, {
    "pattern": "app/model/ItemStockUOMView.js"
}, {
    "pattern": "app/store/ItemStockUOMView.js"
}, {
    "pattern": "app/model/ItemStockView.js"
}, {
    "pattern": "app/store/ItemStockView.js"
}, {
    "pattern": "app/model/LineOfBusiness.js"
}, {
    "pattern": "app/store/LineOfBusiness.js"
}, {
    "pattern": "app/model/Lot.js"
}, {
    "pattern": "app/store/Lot.js"
}, {
    "pattern": "app/model/LotStatus.js"
}, {
    "pattern": "app/store/LotStatus.js"
}, {
    "pattern": "app/model/Manufacturer.js"
}, {
    "pattern": "app/store/Manufacturer.js"
}, {
    "pattern": "app/store/ManufacturingCell.js"
}, {
    "pattern": "app/store/MaterialNMFC.js"
}, {
    "pattern": "app/model/PackTypeDetail.js"
}, {
    "pattern": "app/model/PackType.js"
}, {
    "pattern": "app/store/PackType.js"
}, {
    "pattern": "app/store/PaidOut.js"
}, {
    "pattern": "app/model/ProcessCode.js"
}, {
    "pattern": "app/store/ProcessCode.js"
}, {
    "pattern": "app/model/ReceiptItemLot.js"
}, {
    "pattern": "app/model/ReceiptItemTax.js"
}, {
    "pattern": "app/model/ReceiptItem.js"
}, {
    "pattern": "app/model/ReceiptChargeTax.js"
}, {
    "pattern": "app/model/ReceiptCharge.js"
}, {
    "pattern": "app/model/ReceiptInspection.js"
}, {
    "pattern": "app/model/Receipt.js"
}, {
    "pattern": "app/store/Receipt.js"
}, {
    "pattern": "app/store/ReceiptItemChargeTax.js"
}, {
    "pattern": "app/store/ReceiptItemTax.js"
}, {
    "pattern": "app/model/RebuildInventory.js"
}, {
    "pattern": "app/store/RebuildInventory.js"
}, {
    "pattern": "app/model/ShipmentItemLot.js"
}, {
    "pattern": "app/model/ShipmentItem.js"
}, {
    "pattern": "app/model/ShipmentCharge.js"
}, {
    "pattern": "app/model/Shipment.js"
}, {
    "pattern": "app/store/Shipment.js"
}, {
    "pattern": "app/model/StorageLocationCategory.js"
}, {
    "pattern": "app/model/StorageLocationMeasurement.js"
}, {
    "pattern": "app/model/StorageLocationSku.js"
}, {
    "pattern": "app/model/StorageLocationContainer.js"
}, {
    "pattern": "app/model/StorageLocation.js"
}, {
    "pattern": "app/store/StorageLocation.js"
}, {
    "pattern": "app/model/StorageMeasurementReadingConversion.js"
}, {
    "pattern": "app/model/StorageMeasurementReading.js"
}, {
    "pattern": "app/store/StorageMeasurementReading.js"
}, {
    "pattern": "app/model/StorageUnitType.js"
}, {
    "pattern": "app/store/StorageUnitType.js"
}, {
    "pattern": "app/store/Store.js"
}, {
    "pattern": "app/model/TransferDetail.js"
}, {
    "pattern": "app/model/TransferNote.js"
}, {
    "pattern": "app/model/Transfer.js"
}, {
    "pattern": "app/store/Transfer.js"
}, {
    "pattern": "app/model/UnitMeasureConversion.js"
}, {
    "pattern": "app/model/UnitMeasure.js"
}, {
    "pattern": "app/store/UnitMeasure.js"
}, {
    "pattern": "app/view/Statusbar1.js"
}, {
    "pattern": "app/view/BinToBinTransfer.js"
}, {
    "pattern": "app/store/BufferedManufacturer.js"
}, {
    "pattern": "app/view/BrandViewModel.js"
}, {
    "pattern": "app/view/BrandViewController.js"
}, {
    "pattern": "app/view/Brand.js"
}, {
    "pattern": "app/view/Filter1.js"
}, {
    "pattern": "app/view/StatusbarPaging1.js"
}, {
    "pattern": "app/view/BuildAssemblyBlend.js"
}, {
    "pattern": "app/view/BuildAssemblyBlendViewController.js"
}, {
    "pattern": "app/store/BufferedAssemblyItem.js"
}, {
    "pattern": "app/model/ItemUOM.js"
}, {
    "pattern": "app/store/BufferedItemUnitMeasure.js"
}, {
    "pattern": "app/store/BufferedItemStockUOMView.js"
}, {
    "pattern": "app/view/BuildAssemblyBlendViewModel.js"
}, {
    "pattern": "app/view/CardCount.js"
}, {
    "pattern": "app/view/Category.js"
}, {
    "pattern": "app/view/CategoryLocation.js"
}, {
    "pattern": "app/view/CategoryLocationViewController.js"
}, {
    "pattern": "app/view/CategoryLocationViewModel.js"
}, {
    "pattern": "app/view/CategoryViewController.js"
}, {
    "pattern": "app/store/BufferedUnitMeasure.js"
}, {
    "pattern": "app/store/BufferedCompactItem.js"
}, {
    "pattern": "app/store/BufferedLineOfBusiness.js"
}, {
    "pattern": "app/store/BufferedCategoryLocation.js"
}, {
    "pattern": "app/store/BufferedCategoryUOM.js"
}, {
    "pattern": "app/view/CategoryViewModel.js"
}, {
    "pattern": "app/view/CertificationProgram.js"
}, {
    "pattern": "app/view/CertificationProgramViewController.js"
}, {
    "pattern": "app/model/CompactCommodity.js"
}, {
    "pattern": "app/store/BufferedCommodity.js"
}, {
    "pattern": "app/view/CertificationProgramViewModel.js"
}, {
    "pattern": "app/view/Commodity.js"
}, {
    "pattern": "app/view/CommodityViewController.js"
}, {
    "pattern": "app/model/StorageType.js"
}, {
    "pattern": "app/store/BufferedStorageType.js"
}, {
    "pattern": "app/view/CommodityViewModel.js"
}, {
    "pattern": "app/view/CompanyPreferenceOption.js"
}, {
    "pattern": "app/view/CompanyPreferenceOptionViewController.js"
}, {
    "pattern": "app/view/CompanyPreferenceOptionViewModel.js"
}, {
    "pattern": "app/view/ContractDocument.js"
}, {
    "pattern": "app/view/ContractDocumentViewController.js"
}, {
    "pattern": "app/view/ContractDocumentViewModel.js"
}, {
    "pattern": "app/view/CountGroupViewModel.js"
}, {
    "pattern": "app/view/CountGroupViewController.js"
}, {
    "pattern": "app/view/CountGroup.js"
}, {
    "pattern": "app/view/FactoryUnitType.js"
}, {
    "pattern": "app/view/FactoryUnitTypeViewController.js"
}, {
    "pattern": "app/view/FactoryUnitTypeViewModel.js"
}, {
    "pattern": "app/view/FeedStockCodeViewModel.js"
}, {
    "pattern": "app/view/FeedStockCodeViewController.js"
}, {
    "pattern": "app/view/FeedStockCode.js"
}, {
    "pattern": "app/view/FeedStockUomViewModel.js"
}, {
    "pattern": "app/view/FeedStockUomViewController.js"
}, {
    "pattern": "app/view/FeedStockUom.js"
}, {
    "pattern": "app/view/Filter1ViewController.js"
}, {
    "pattern": "app/view/Filter1ViewModel.js"
}, {
    "pattern": "app/view/FuelCategoryViewModel.js"
}, {
    "pattern": "app/view/FuelCategory.js"
}, {
    "pattern": "app/view/FuelCategoryViewController.js"
}, {
    "pattern": "app/view/FuelCodeViewModel.js"
}, {
    "pattern": "app/view/FuelCodeViewController.js"
}, {
    "pattern": "app/view/FuelCode.js"
}, {
    "pattern": "app/view/FuelTank.js"
}, {
    "pattern": "app/view/FuelTankViewController.js"
}, {
    "pattern": "app/view/FuelTankViewModel.js"
}, {
    "pattern": "app/view/FuelTaxClass.js"
}, {
    "pattern": "app/view/FuelTaxClassViewController.js"
}, {
    "pattern": "app/view/FuelTaxClassViewModel.js"
}, {
    "pattern": "app/view/FuelType.js"
}, {
    "pattern": "app/view/FuelTypeViewController.js"
}, {
    "pattern": "app/store/BufferedFeedStockCode.js"
}, {
    "pattern": "app/store/BufferedFeedStockUOM.js"
}, {
    "pattern": "app/store/BufferedFuelCategory.js"
}, {
    "pattern": "app/store/BufferedFuelCode.js"
}, {
    "pattern": "app/store/BufferedProcessCode.js"
}, {
    "pattern": "app/view/FuelTypeViewModel.js"
}, {
    "pattern": "app/view/ImportDataFromCsv.js"
}, {
    "pattern": "app/view/ImportDataFromCsvViewController.js"
}, {
    "pattern": "app/view/ImportDataFromCsvViewModel.js"
}, {
    "pattern": "app/view/ImportLogMessageBox.js"
}, {
    "pattern": "app/view/ImportLogMessageBoxViewController.js"
}, {
    "pattern": "app/view/ImportLogMessageBoxViewModel.js"
}, {
    "pattern": "app/view/InventoryAdjustment.js"
}, {
    "pattern": "app/view/InventoryAdjustmentViewController.js"
}, {
    "pattern": "app/store/BufferedItemStockView.js"
}, {
    "pattern": "app/store/BufferedStockTrackingItemView.js"
}, {
    "pattern": "app/store/BufferedStorageLocation.js"
}, {
    "pattern": "app/store/BufferedLot.js"
}, {
    "pattern": "app/store/BufferedPostedLot.js"
}, {
    "pattern": "app/store/BufferedItemWeightUOM.js"
}, {
    "pattern": "app/store/BufferedLotStatus.js"
}, {
    "pattern": "app/model/ItemStockUOMForAdjustmentView.js"
}, {
    "pattern": "app/store/BufferedItemStockUOMForAdjustmentView.js"
}, {
    "pattern": "app/view/InventoryAdjustmentViewModel.js"
}, {
    "pattern": "app/view/InventoryBaseViewController.js"
}, {
    "pattern": "app/view/InventoryCount.js"
}, {
    "pattern": "app/view/InventoryCountGroup.js"
}, {
    "pattern": "app/view/InventoryCountGroupViewController.js"
}, {
    "pattern": "app/view/InventoryCountGroupViewModel.js"
}, {
    "pattern": "app/view/InventoryCountViewController.js"
}, {
    "pattern": "app/store/BufferedCategory.js"
}, {
    "pattern": "app/store/BufferedCountGroup.js"
}, {
    "pattern": "app/store/ItemStockSummary.js"
}, {
    "pattern": "app/store/ItemStockSummaryByLot.js"
}, {
    "pattern": "app/view/InventoryCountViewModel.js"
}, {
    "pattern": "app/view/InventoryReceipt.js"
}, {
    "pattern": "app/view/InventoryReceiptTaxesViewController.js"
}, {
    "pattern": "app/view/InventoryReceiptTaxesViewModel.js"
}, {
    "pattern": "app/view/InventoryReceiptTaxes.js"
}, {
    "pattern": "app/view/InventoryReceiptViewController.js"
}, {
    "pattern": "app/model/EquipmentLength.js"
}, {
    "pattern": "app/store/BufferedEquipmentLength.js"
}, {
    "pattern": "app/model/QAProperty.js"
}, {
    "pattern": "app/store/BufferedQAProperty.js"
}, {
    "pattern": "app/model/ItemStockDetailAccount.js"
}, {
    "pattern": "app/model/ItemStockDetailPricing.js"
}, {
    "pattern": "app/model/ItemStockDetailView.js"
}, {
    "pattern": "app/store/BufferedItemStockDetailView.js"
}, {
    "pattern": "app/store/BufferedItemPricingView.js"
}, {
    "pattern": "app/store/BufferedItemWeightVolumeUOM.js"
}, {
    "pattern": "app/model/PackedUOM.js"
}, {
    "pattern": "app/store/BufferedPackedUOM.js"
}, {
    "pattern": "app/model/ParentLot.js"
}, {
    "pattern": "app/store/BufferedParentLot.js"
}, {
    "pattern": "app/store/BufferedOtherCharges.js"
}, {
    "pattern": "app/store/BufferedGradeAttribute.js"
}, {
    "pattern": "app/model/ReceiptItemView.js"
}, {
    "pattern": "app/store/BufferedReceiptItemView.js"
}, {
    "pattern": "app/view/InventoryReceiptViewModel.js"
}, {
    "pattern": "app/view/InventoryShipment.js"
}, {
    "pattern": "app/view/InventoryShipmentViewController.js"
}, {
    "pattern": "app/view/InventoryShipmentViewModel.js"
}, {
    "pattern": "app/view/InventoryTag.js"
}, {
    "pattern": "app/view/InventoryTagViewController.js"
}, {
    "pattern": "app/view/InventoryTagViewModel.js"
}, {
    "pattern": "app/view/InventoryTransfer.js"
}, {
    "pattern": "app/view/InventoryTransferViewController.js"
}, {
    "pattern": "app/model/Status.js"
}, {
    "pattern": "app/store/BufferedStatus.js"
}, {
    "pattern": "app/model/ItemStockUOMViewTotals.js"
}, {
    "pattern": "app/store/BufferedItemStockUOMViewTotals.js"
}, {
    "pattern": "app/view/InventoryTransferViewModel.js"
}, {
    "pattern": "app/view/InventoryUOM.js"
}, {
    "pattern": "app/view/InventoryUOMViewController.js"
}, {
    "pattern": "app/view/InventoryUOMViewModel.js"
}, {
    "pattern": "app/view/InventoryValuation.js"
}, {
    "pattern": "app/view/InventoryValuationSummary.js"
}, {
    "pattern": "app/view/InventoryValuationSummaryViewController.js"
}, {
    "pattern": "app/view/InventoryValuationSummaryViewModel.js"
}, {
    "pattern": "app/view/InventoryValuationViewController.js"
}, {
    "pattern": "app/view/InventoryValuationViewModel.js"
}, {
    "pattern": "app/view/Item.js"
}, {
    "pattern": "app/view/ItemLocation.js"
}, {
    "pattern": "app/view/ItemLocationViewController.js"
}, {
    "pattern": "app/store/BufferedItemUPC.js"
}, {
    "pattern": "app/view/ItemLocationViewModel.js"
}, {
    "pattern": "app/view/ItemSubstitution.js"
}, {
    "pattern": "app/view/ItemSubstitutionViewController.js"
}, {
    "pattern": "app/view/ItemSubstitutionViewModel.js"
}, {
    "pattern": "app/view/ItemViewController.js"
}, {
    "pattern": "app/store/BufferedInventoryTag.js"
}, {
    "pattern": "app/store/BufferedItemLocation.js"
}, {
    "pattern": "app/store/BufferedBrand.js"
}, {
    "pattern": "app/store/BufferedFuelTaxClass.js"
}, {
    "pattern": "app/store/BufferedDocument.js"
}, {
    "pattern": "app/store/BufferedCertification.js"
}, {
    "pattern": "app/store/BufferedClassAttribute.js"
}, {
    "pattern": "app/store/BufferedRegionAttribute.js"
}, {
    "pattern": "app/store/BufferedOriginAttribute.js"
}, {
    "pattern": "app/store/BufferedProductLineAttribute.js"
}, {
    "pattern": "app/store/BufferedProductTypeAttribute.js"
}, {
    "pattern": "app/store/BufferedSeasonAttribute.js"
}, {
    "pattern": "app/view/ItemViewModel.js"
}, {
    "pattern": "app/view/LineOfBusinessViewModel.js"
}, {
    "pattern": "app/view/LineOfBusinessViewController.js"
}, {
    "pattern": "app/view/LineOfBusiness.js"
}, {
    "pattern": "app/view/LotDetail.js"
}, {
    "pattern": "app/view/LotDetailViewController.js"
}, {
    "pattern": "app/view/LotDetailViewModel.js"
}, {
    "pattern": "app/view/LotStatusViewModel.js"
}, {
    "pattern": "app/view/LotStatusViewController.js"
}, {
    "pattern": "app/view/LotStatus.js"
}, {
    "pattern": "app/view/ManufacturerViewModel.js"
}, {
    "pattern": "app/view/ManufacturerViewController.js"
}, {
    "pattern": "app/view/Manufacturer.js"
}, {
    "pattern": "app/view/ManufacturingCell.js"
}, {
    "pattern": "app/view/ManufacturingCellViewController.js"
}, {
    "pattern": "app/view/ManufacturingCellViewModel.js"
}, {
    "pattern": "app/view/MaterialMovementMap.js"
}, {
    "pattern": "app/view/OriginConversionOption.js"
}, {
    "pattern": "app/view/OriginConversionOptionViewController.js"
}, {
    "pattern": "app/view/OriginConversionOptionViewModel.js"
}, {
    "pattern": "app/view/PickLot.js"
}, {
    "pattern": "app/view/PickLotViewController.js"
}, {
    "pattern": "app/view/PickLotViewModel.js"
}, {
    "pattern": "app/view/ProcessCodeViewModel.js"
}, {
    "pattern": "app/view/ProcessCodeViewController.js"
}, {
    "pattern": "app/view/ProcessCode.js"
}, {
    "pattern": "app/view/Reason.js"
}, {
    "pattern": "app/view/ReasonViewController.js"
}, {
    "pattern": "app/view/ReasonViewModel.js"
}, {
    "pattern": "app/view/RebuildInventory.js"
}, {
    "pattern": "app/model/ItemVendorXref.js"
}, {
    "pattern": "app/model/ItemCustomerXref.js"
}, {
    "pattern": "app/model/ItemContractDocument.js"
}, {
    "pattern": "app/model/ItemContract.js"
}, {
    "pattern": "app/model/ItemCertification.js"
}, {
    "pattern": "app/model/ItemPOSSLA.js"
}, {
    "pattern": "app/model/ItemPOSCategory.js"
}, {
    "pattern": "app/model/ItemManufacturingUOM.js"
}, {
    "pattern": "app/model/ItemAccount.js"
}, {
    "pattern": "app/model/ItemCommodityCost.js"
}, {
    "pattern": "app/model/ItemStock.js"
}, {
    "pattern": "app/model/ItemPricingLevel.js"
}, {
    "pattern": "app/model/ItemSpecialPricing.js"
}, {
    "pattern": "app/model/ItemAssembly.js"
}, {
    "pattern": "app/model/ItemBundle.js"
}, {
    "pattern": "app/model/ItemKitDetail.js"
}, {
    "pattern": "app/model/ItemKit.js"
}, {
    "pattern": "app/model/ItemNote.js"
}, {
    "pattern": "app/model/ItemOwner.js"
}, {
    "pattern": "app/model/ItemFactoryManufacturingCell.js"
}, {
    "pattern": "app/model/ItemFactory.js"
}, {
    "pattern": "app/model/ItemMotorFuelTax.js"
}, {
    "pattern": "app/model/Item.js"
}, {
    "pattern": "app/store/Item.js"
}, {
    "pattern": "app/model/FiscalPeriod.js"
}, {
    "pattern": "app/store/FiscalPeriod.js"
}, {
    "pattern": "app/view/RebuildInventoryViewModel.js"
}, {
    "pattern": "app/view/Statusbar1ViewController.js"
}, {
    "pattern": "app/view/Statusbar1ViewModel.js"
}, {
    "pattern": "app/view/StatusbarPaging1ViewController.js"
}, {
    "pattern": "app/view/StatusbarPaging1ViewModel.js"
}, {
    "pattern": "app/view/StockDetail.js"
}, {
    "pattern": "app/view/StockDetailViewController.js"
}, {
    "pattern": "app/view/StockDetailViewModel.js"
}, {
    "pattern": "app/view/StorageMeasurementReading.js"
}, {
    "pattern": "app/view/StorageMeasurementReadingViewModel.js"
}, {
    "pattern": "app/view/StorageUnit.js"
}, {
    "pattern": "app/view/StorageUnitViewController.js"
}, {
    "pattern": "app/store/BufferedStorageUnitType.js"
}, {
    "pattern": "app/model/Restriction.js"
}, {
    "pattern": "app/store/BufferedRestriction.js"
}, {
    "pattern": "app/model/Measurement.js"
}, {
    "pattern": "app/store/BufferedMeasurement.js"
}, {
    "pattern": "app/model/ReadingPoint.js"
}, {
    "pattern": "app/store/BufferedReadingPoint.js"
}, {
    "pattern": "app/view/StorageUnitViewModel.js"
}, {
    "pattern": "app/view/Main.js"
}, {
    "pattern": "app/view/Viewport.js"
}];

var mockFiles = [
    {pattern: 'test/mock/**/*.js', watched: true}
];
var testFiles = [
    {pattern: 'node_modules/extjs-spec-generator/src/UnitTestEngine.js', watched: true},
    {pattern: 'test/specs/**/*.spec.js', watched: true}
];

var libs = [
    {pattern: 'app/lib/rx.all.js', watched: true },
    {pattern: 'app/lib/underscore.js', watched: true }
];

var files = libs.concat(extJs).concat(mockFiles).concat(inventoryFiles).concat(testFiles);

module.exports = function (config) {
    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: '',


        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        // 'jasmine',
        frameworks: ['mocha', 'chai'],


        // list of files / patterns to load in the browser
        files: files,


        // list of files to exclude
        exclude: [],


        // preprocess matching files before serving them to the browser
        // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
       //preprocessors: { 'app/**/*.js': ['coverage'] },


        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['mocha'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['PhantomJS'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        // Concurrency level
        // how many browser should be started simultaneous
        concurrency: Infinity
    });
};

