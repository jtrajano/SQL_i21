UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStatus',
    alias: "store.icbufferedstatus",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Status"],
    config: {}
});