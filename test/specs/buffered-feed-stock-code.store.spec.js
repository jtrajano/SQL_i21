UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFeedStockCode',
    alias: "store.icbufferedfeedstockcode",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FeedStockCode"],
    config: {}
});