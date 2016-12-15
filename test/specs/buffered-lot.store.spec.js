UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLot',
    alias: "store.icbufferedlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Lot"],
    config: {}
});