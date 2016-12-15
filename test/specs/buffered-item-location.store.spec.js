UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemLocation',
    alias: "store.icbuffereditemlocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemLocation"],
    config: {}
});