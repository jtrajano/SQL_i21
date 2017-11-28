UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemSubLocations',
    alias: "store.icbuffereditemsublocations",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemSubLocation"],
    config: {
        "model": "Inventory.model.ItemSubLocation",
        "storeId": "BufferedItemSubLocationsStore",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/searchitemsublocations"
            }
        }
    }
});