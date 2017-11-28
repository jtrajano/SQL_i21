UnitTestEngine.testViewModel({
    name: 'Inventory.view.InventoryCountViewModel',
    alias: 'viewmodel.icinventorycount',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedCategory", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedCountGroup", "Inventory.store.BufferedStorageLocation", "Inventory.store.BufferedItemUnitMeasure", "Inventory.store.ItemStockSummary", "Inventory.store.ItemStockSummaryByLot", "Inventory.store.BufferedItemStockView", "Inventory.store.BufferedItemStockUOMView", "Inventory.store.BufferedLot", "Inventory.store.BufferedParentLot", "i21.store.CompanyLocationBuffered", "i21.store.CompanyLocationSubLocationBuffered", "Inventory.store.BufferedItemStockUOMForAdjustmentView", "GeneralLedger.controls.RecapTab", "GeneralLedger.controls.PostHistory", "Inventory.store.BufferedItemSubLocationsLookup", "Inventory.store.BufferedItemStorageLocationsLookup"]
});