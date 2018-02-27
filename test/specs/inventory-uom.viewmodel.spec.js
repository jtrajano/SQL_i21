UnitTestEngine.testViewModel({
    name: 'Inventory.view.InventoryUOMViewModel',
    alias: 'viewmodel.icinventoryuom',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.UnitMeasure", "Inventory.store.BufferedValidTargetUOM"]
});