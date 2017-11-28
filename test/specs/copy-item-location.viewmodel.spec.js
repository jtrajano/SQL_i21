UnitTestEngine.testViewModel({
    name: 'Inventory.view.CopyItemLocationViewModel',
    alias: 'viewmodel.iccopyitemlocation',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedItem", "Inventory.store.Item"]
});