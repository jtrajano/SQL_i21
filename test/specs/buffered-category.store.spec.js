UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategory',
    alias: "store.icbufferedcategory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Category"],
    config: {}
});