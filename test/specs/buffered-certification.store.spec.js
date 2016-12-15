UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCertification',
    alias: "store.icbufferedcertification",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Certification"],
    config: {}
});