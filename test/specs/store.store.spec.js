UnitTestEngine.testStore({
    name: 'Inventory.store.Store',
    alias: "store.storestore",
    base: 'Ext.data.BufferedStore',
    dependencies: [],
    config: {
        "storeId": "Store",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Store/GetStores"
            }
        }
    }
});