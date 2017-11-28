UnitTestEngine.testViewModel({
    name: 'Inventory.view.InventoryCountDetailsViewModel',
    alias: 'viewmodel.icinventorycountdetails',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedCategory", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedCountGroup", "Inventory.store.BufferedStorageLocation", "Inventory.store.BufferedItemUnitMeasure", "Inventory.store.ItemStockSummary", "Inventory.store.ItemStockSummaryByLot", "Inventory.store.BufferedItemStockView", "Inventory.store.BufferedItemStockUOMView", "Inventory.store.BufferedParentLot", "Inventory.store.BufferedLot", "i21.store.CompanyLocationBuffered", "i21.store.CompanyLocationSubLocationBuffered", "Inventory.store.BufferedItemStockUOMForAdjustmentView", "Inventory.store.BufferedInventoryCountStockItem", "Inventory.store.BufferedItemSubLocationsLookup", "Inventory.store.BufferedItemStorageLocationsLookup"]
});