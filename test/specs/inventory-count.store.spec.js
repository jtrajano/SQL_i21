UnitTestEngine.testStore({
    name: 'Inventory.store.InventoryCount',
    alias: "store.icinventorycount",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.InventoryCount"],
    config: {
        "model": "Inventory.model.InventoryCount",
        "storeId": "InventoryCount",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryCount/Get",
                "update": "../Inventory/api/InventoryCount/Put",
                "create": "../Inventory/api/InventoryCount/Post"
            }
        }
    }
});