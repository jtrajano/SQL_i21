UnitTestEngine.testStore({
    name: 'Inventory.store.Store',
    alias: "store.storestore",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: [],
    config: {
        "storeId": "Store",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/store/getstores"
            }
        }
    }
});