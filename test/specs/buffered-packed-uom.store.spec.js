UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedPackedUOM',
    alias: "store.icbufferedpackeduom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.PackedUOM"],
    config: {}
});