UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStockTrackingItemView',
    alias: "store.icbufferedstocktrackingitemview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {}
});