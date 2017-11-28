UnitTestEngine.testStore({
    name: 'Inventory.store.Transfer',
    alias: "store.ictransfer",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Transfer"],
    config: {
        "model": "Inventory.model.Transfer",
        "storeId": "Transfer",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventorytransfer/get",
                "update": "./inventory/api/inventorytransfer/put",
                "create": "./inventory/api/inventorytransfer/post"
            }
        }
    }
});