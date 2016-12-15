UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedMeasurement',
    alias: "store.icbufferedmeasurement",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Measurement"],
    config: {}
});