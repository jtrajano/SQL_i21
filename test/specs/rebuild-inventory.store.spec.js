UnitTestEngine.testStore({
    name: 'Inventory.store.RebuildInventory',
    alias: "store.icrebuildinventory",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.RebuildInventory"],
    config: {
        "model": "Inventory.model.RebuildInventory",
        "storeId": "RebuildInventory"
    }
});