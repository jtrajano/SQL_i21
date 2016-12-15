UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedDocument',
    alias: "store.icbuffereddocument",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Document"],
    config: {}
});