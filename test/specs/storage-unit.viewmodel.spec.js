UnitTestEngine.testViewModel({
    name: 'Inventory.view.StorageUnitViewModel',
    alias: 'viewmodel.icstorageunit',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedUnitMeasure", "Inventory.store.BufferedCategory", "Inventory.store.BufferedStorageUnitType", "Inventory.store.BufferedStorageLocation", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedRestriction", "Inventory.store.BufferedMeasurement", "Inventory.store.BufferedReadingPoint", "i21.store.CompanyLocationBuffered", "i21.store.CompanyLocationSubLocationBuffered", "Inventory.store.BufferedItemStockDetailView"]
});