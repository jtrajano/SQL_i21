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
                "read": "../Inventory/api/StorageLocation/Get",
                "update": "../Inventory/api/StorageLocation/Put",
                "create": "../Inventory/api/StorageLocation/Post"
            }
        }
    }
});