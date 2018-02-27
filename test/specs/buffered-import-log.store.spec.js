UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedImportLog',
    alias: "store.icbufferedimportlog",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ImportLog"],
    config: {
        "model": "Inventory.model.ImportLog",
        "storeId": "BufferedImportLog",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/importlog/searchimportlogs"
            }
        }
    }
});