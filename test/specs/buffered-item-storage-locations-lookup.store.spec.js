UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemStorageLocationsLookup',
    alias: "store.icbuffereditemstoragelocationslookup",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemStorageLocationsLookup"],
    config: {
        "model": "Inventory.model.ItemStorageLocationsLookup",
        "storeId": "BufferedItemStorageLocationsLookup",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itemstock/getitemstoragelocations"
            }
        }
    }
});