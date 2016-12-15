UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelCode',
    alias: "store.icbufferedfuelcode",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelCode"],
    config: {}
});