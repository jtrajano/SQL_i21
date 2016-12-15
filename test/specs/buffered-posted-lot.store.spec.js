UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedPostedLot',
    alias: "store.icbufferedpostedlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Lot"],
    config: {}
});