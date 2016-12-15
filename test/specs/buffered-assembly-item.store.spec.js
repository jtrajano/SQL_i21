UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedAssemblyItem',
    alias: "store.icbufferedassemblyitem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {}
});