UnitTestEngine.testStore({
    name: 'Inventory.store.RepostInventory',
    alias: "store.icrepostinventory",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.RepostInventory"],
    config: {
        "model": "Inventory.model.RepostInventory",
        "storeId": "RepostInventory"
    }
});