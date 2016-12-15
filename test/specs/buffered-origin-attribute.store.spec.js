UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedOriginAttribute',
    alias: "store.icbufferedoriginattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityOrigin"],
    config: {}
});