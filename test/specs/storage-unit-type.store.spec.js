UnitTestEngine.testStore({
    name: 'Inventory.store.StorageUnitType',
    alias: null,
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.StorageUnitType"],
    config: {
        "model": "Inventory.model.StorageUnitType",
        "storeId": "StorageUnitType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/StorageUnitType/Get",
                "update": "../Inventory/api/StorageUnitType/Put",
                "create": "../Inventory/api/StorageUnitType/Post"
            }
        }
    }
});