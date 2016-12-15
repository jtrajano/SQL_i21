UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemUPC',
    alias: "store.icbuffereditemupc",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {}
});