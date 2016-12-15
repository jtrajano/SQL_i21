UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemWeightVolumeUOM',
    alias: "store.icbuffereditemweightvolumeuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {}
});