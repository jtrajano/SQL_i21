UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCategoryUOM',
    alias: "store.icbufferedcategoryuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CategoryUOM"],
    config: {}
});