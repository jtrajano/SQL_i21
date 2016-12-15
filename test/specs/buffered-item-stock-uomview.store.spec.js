UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStockUOMView',
    alias: "store.icbuffereditemstockuomview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStockUOMView"],
    config: {}
});