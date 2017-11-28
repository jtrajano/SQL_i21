UnitTestEngine.testViewModel({
    name: 'Inventory.view.PickLotViewModel',
    alias: 'viewmodel.icpicklot',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedItemStockView", "Inventory.store.BufferedStorageLocation"]
});