UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLineOfBusiness',
    alias: "store.icbufferedlineofbusiness",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LineOfBusiness"],
    config: {}
});