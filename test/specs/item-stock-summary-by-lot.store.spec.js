UnitTestEngine.testStore({
    name: 'Inventory.store.ItemStockSummaryByLot',
    alias: "store.icitemstocksummarybylot",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemStockSummary"],
    config: {}
});