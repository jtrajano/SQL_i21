UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockSummary',
    alias: "store.icbuffereditemstocksummary",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {}
});