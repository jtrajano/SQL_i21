UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelCategory',
    alias: "store.icbufferedfuelcategory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelCategory"],
    config: {}
});