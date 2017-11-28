UnitTestEngine.testStore({
    name: 'Inventory.store.StorageLocation',
    alias: "store.icstoragelocation",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.StorageLocation"],
    config: {
        "model": "Inventory.model.StorageLocation",
        "storeId": "StorageLocation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/storagelocation/get",
                "update": "./inventory/api/storagelocation/put",
                "create": "./inventory/api/storagelocation/post"
            }
        }
    }
});