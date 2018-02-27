UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedImportLogDetail',
    alias: "store.icbufferedimportlogdetail",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ImportLogDetail"],
    config: {
        "model": "Inventory.model.ImportLogDetail",
        "storeId": "BufferedImportLogDetail",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/importlogdetail/searchimportlogdetails"
            }
        }
    }
});