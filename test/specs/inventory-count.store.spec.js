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
                "read": "./inventory/api/inventorycount/get",
                "update": "./inventory/api/inventorycount/put",
                "create": "./inventory/api/inventorycount/post"
            }
        }
    }
});