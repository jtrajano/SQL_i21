UnitTestEngine.testViewModel({
    name: 'Inventory.view.FuelTypeViewModel',
    alias: 'viewmodel.icfueltype',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedFeedStockCode", "Inventory.store.BufferedFeedStockUom", "Inventory.store.BufferedFuelCategory", "Inventory.store.BufferedFuelCode", "Inventory.store.BufferedProductionProcess"]
});