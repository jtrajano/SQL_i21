UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMViewTotals',
    alias: "store.icbuffereditemstockuomviewtotals",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMViewTotals"],
    config: {}
});