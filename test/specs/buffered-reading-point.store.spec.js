UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedReadingPoint',
    alias: "store.icbufferedreadingpoint",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ReadingPoint"],
    config: {}
});