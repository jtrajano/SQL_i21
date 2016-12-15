UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedParentLot',
    alias: "store.icbufferedparentlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ParentLot"],
    config: {}
});