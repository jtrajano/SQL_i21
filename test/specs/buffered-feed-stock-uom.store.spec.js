UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFeedStockUom',
    alias: "store.icbufferedfeedstockuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FeedStockUom"],
    config: {}
});