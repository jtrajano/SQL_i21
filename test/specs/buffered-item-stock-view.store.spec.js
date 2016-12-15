UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockView',
    alias: "store.icbuffereditemstockview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockView"],
    config: {}
});