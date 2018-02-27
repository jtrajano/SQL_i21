UnitTestEngine.testStore({
    name: 'Inventory.store.ImportLog',
    alias: "store.icimportlog",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ImportLog"],
    config: {
        "model": "Inventory.model.ImportLog",
        "storeId": "ImportLog",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/importlog/get"
            }
        }
    }
});