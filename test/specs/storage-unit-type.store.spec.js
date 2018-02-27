UnitTestEngine.testStore({
    name: 'Inventory.store.StorageUnitType',
    alias: null,
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.StorageUnitType"],
    config: {
        "model": "Inventory.model.StorageUnitType",
        "storeId": "StorageUnitType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/storageunittype/get",
                "update": "./inventory/api/storageunittype/put",
                "create": "./inventory/api/storageunittype/post"
            }
        }
    }
});