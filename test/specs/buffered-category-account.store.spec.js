UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryAccount',
    alias: "store.icbufferedcategoryaccount",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryAccount"],
    config: {}
});