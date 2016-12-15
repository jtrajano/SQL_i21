UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProductTypeAttribute',
    alias: "store.icbufferedproducttypeattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityProductType"],
    config: {}
});