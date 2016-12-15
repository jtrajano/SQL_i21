UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemCommodity',
    alias: "store.icbuffereditemcommodity",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {}
});