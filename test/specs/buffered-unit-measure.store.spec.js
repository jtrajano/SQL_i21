UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedUnitMeasure',
    alias: "store.icbuffereduom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.UnitMeasure"],
    config: {}
});