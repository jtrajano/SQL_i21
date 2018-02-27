UnitTestEngine.testStore({
    name: 'Inventory.store.ImportLogDetail',
    alias: "store.icimportlogDetail",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ImportLogDetail"],
    config: {
        "model": "Inventory.model.ImportLogDetail",
        "storeId": "ImportLogDetail",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/importlogdetail/get"
            }
        }
    }
});