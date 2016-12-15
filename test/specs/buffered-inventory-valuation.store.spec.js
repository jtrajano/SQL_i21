UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryValuation',
    alias: "store.icbufferedinventoryvaluation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.InventoryValuation"],
    config: {}
});