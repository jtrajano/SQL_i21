UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageType',
    alias: "store.icbufferedstoragetype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageType"],
    config: {}
});