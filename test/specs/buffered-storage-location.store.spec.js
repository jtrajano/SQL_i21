UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageLocation',
    alias: "store.icbufferedstoragelocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageLocation"],
    config: {}
});