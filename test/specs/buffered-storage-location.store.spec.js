UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStorageLocation',
    alias: "store.icbufferedstoragelocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.StorageLocation"],
    config: {
        "model": "Inventory.model.StorageLocation",
        "storeId": "BufferedStorageLocation",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/StorageLocation/Search"
            }
        }
    }
});