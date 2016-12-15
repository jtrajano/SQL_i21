UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryLocation',
    alias: "store.icbufferedcategorylocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryLocation"],
    config: {}
});