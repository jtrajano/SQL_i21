UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemSubLocationsLookup',
    alias: "store.icbuffereditemsublocationslookup",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemSubLocationsLookup"],
    config: {
        "model": "Inventory.model.ItemSubLocationsLookup",
        "storeId": "BufferedItemSubLocationsLookup",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itemstock/getitemsublocations"
            }
        }
    }
});