UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCountGroup',
    alias: "store.icbufferedcountgroup",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CountGroup"],
    config: {}
});