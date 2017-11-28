UnitTestEngine.testViewModel({
    name: 'Inventory.view.StorageMeasurementReadingViewModel',
    alias: 'viewmodel.icstoragemeasurementreading',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedItemStockView", "Inventory.store.BufferedItemStockUOMView", "Inventory.store.BufferedStorageLocation", "Grain.store.BufferedDiscountSchedule", "Inventory.store.BufferedStorageUnitStock"]
});