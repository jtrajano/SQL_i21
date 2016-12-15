UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedManufacturer',
    alias: "store.icbufferedmanufacturer",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Manufacturer"],
    config: {}
});