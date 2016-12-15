UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedSeasonAttribute',
    alias: "store.icbufferedseasonattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommoditySeason"],
    config: {}
});