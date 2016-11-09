UnitTestEngine.testStore({
    name: 'Inventory.store.Receipt',
    alias: "store.icreceipt",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Receipt"],
    config: {
        "model": "Inventory.model.Receipt",
        "storeId": "Receipt",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryReceipt/Get",
                "update": "../Inventory/api/InventoryReceipt/Put",
                "create": "../Inventory/api/InventoryReceipt/Post"
            }
        }
    }
});