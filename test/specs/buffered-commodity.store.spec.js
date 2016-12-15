UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCommodity',
    alias: "store.icbufferedcommodity",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactCommodity"],
    config: {}
});