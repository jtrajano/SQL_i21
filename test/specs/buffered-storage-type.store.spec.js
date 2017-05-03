UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageType',
    alias: "store.icbufferedstoragetype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageType"],
    config: {
        "model": "Inventory.model.StorageType",
        "storeId": "BufferedStorageType",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/StorageType/Search"
            }
        }
    }
});