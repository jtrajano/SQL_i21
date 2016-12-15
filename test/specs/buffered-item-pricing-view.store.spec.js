UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemPricingView',
    alias: "store.icbuffereditempricingview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockDetailPricing"],
    config: {}
});