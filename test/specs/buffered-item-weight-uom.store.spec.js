UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemWeightUOM',
    alias: "store.icbuffereditemweightuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {}
});