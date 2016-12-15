UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemFactory',
    alias: "store.icbuffereditemfactory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItemFactory"],
    config: {}
});