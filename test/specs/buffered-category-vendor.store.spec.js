UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryVendor',
    alias: "store.icbufferedcategoryvendor",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryVendor"],
    config: {}
});