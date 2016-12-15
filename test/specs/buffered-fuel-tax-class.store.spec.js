UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelTaxClass',
    alias: "store.icbufferedfueltaxclass",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelTaxClass"],
    config: {}
});