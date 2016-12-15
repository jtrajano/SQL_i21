UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedSku',
    alias: "store.icbufferedsku",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Sku"],
    config: {}
});