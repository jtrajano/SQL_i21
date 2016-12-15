UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProductLineAttribute',
    alias: "store.icbufferedproductlineattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityProductLine"],
    config: {}
});