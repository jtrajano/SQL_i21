UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageUnitStock',
    alias: "store.icbufferedstorageunitstock",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageUnitStock"],
    config: {
        "model": "Inventory.model.StorageUnitStock",
        "storeId": "BufferedStorageUnitStock",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/storagelocation/getstorageunitstock"
            }
        }
    }
});