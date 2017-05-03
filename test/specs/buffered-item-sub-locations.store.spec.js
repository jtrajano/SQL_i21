UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemSubLocations',
    alias: "store.icbuffereditemsublocations",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemSubLocations"],
    config: {
        "model": "Inventory.model.ItemSubLocations",
        "storeId": "BufferedItemSubLocationsStore",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemSubLocations"
            }
        }
    }
});