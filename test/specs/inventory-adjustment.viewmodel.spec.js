UnitTestEngine.testViewModel({
    name: 'Inventory.view.InventoryAdjustmentViewModel',
    alias: 'viewmodel.icinventoryadjustment',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "i21.store.CompanyLocationSubLocationBuffered", "GeneralLedger.store.BufAccountId", "GeneralLedger.store.BufAccountCategoryGroup", "Inventory.store.BufferedItemStockView", "Inventory.store.BufferedStockTrackingItemView", "Inventory.store.BufferedStorageLocation", "Inventory.store.BufferedLot", "Inventory.store.BufferedPostedLot", "Inventory.store.BufferedItemUnitMeasure", "Inventory.store.BufferedItemWeightUOM", "Inventory.store.BufferedLotStatus", "Inventory.store.BufferedItemStockUOMForAdjustmentView", "Inventory.store.BufferedItemOwner", "Inventory.store.BufferedItemStockUOMView", "GeneralLedger.controls.RecapTab", "GeneralLedger.controls.PostHistory", "Inventory.store.BufferedItemSubLocationsLookup", "Inventory.store.BufferedItemStorageLocationsLookup"]
});