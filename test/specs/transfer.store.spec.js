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
                "read": "../Inventory/api/InventoryTransfer/Get",
                "update": "../Inventory/api/InventoryTransfer/Put",
                "create": "../Inventory/api/InventoryTransfer/Post"
            }
        }
    }
});