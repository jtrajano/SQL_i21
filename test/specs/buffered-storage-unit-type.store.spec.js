UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageUnitType',
    alias: "store.icbufferedstorageunittype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageUnitType"],
    config: {
        "model": "Inventory.model.StorageUnitType",
        "storeId": "BufferedStorageUnitType",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/StorageUnitType/Search"
            }
        }
    }
});