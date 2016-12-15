UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelType',
    alias: "store.icbufferedfueltype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelType"],
    config: {}
});