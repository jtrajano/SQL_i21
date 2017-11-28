UnitTestEngine.testViewModel({
    name: 'Inventory.view.RebuildInventoryViewModel',
    alias: 'viewmodel.icrebuildinventory',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedItem", "Inventory.store.FiscalPeriod"]
});