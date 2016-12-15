UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCompactItem',
    alias: "store.icbufferedcompactitem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {}
});