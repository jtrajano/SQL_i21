UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedOtherCharges',
    alias: "store.icbufferedothercharges",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {}
});