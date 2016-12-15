UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLotStatus',
    alias: "store.icbufferedlotstatus",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LotStatus"],
    config: {}
});