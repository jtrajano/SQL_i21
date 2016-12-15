UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedGradeAttribute',
    alias: "store.icbufferedgradeattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityGrade"],
    config: {}
});