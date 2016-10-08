Inventory.TestUtils.testStore({
    name: 'Inventory.store.Item',
    alias: 'store.icitem',
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Item"],
    config: [{
        "model": "Inventory.model.Item",
        "storeId": "Item",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/Get",
                "update": "../Inventory/api/Item/Put",
                "create": "../Inventory/api/Item/Post"
            }
        }
    }]
});