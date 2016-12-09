UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedStatus',
    alias: "store.icbufferedstatus",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Status"],
    config: {
        "model": "Inventory.model.Status",
        "storeId": "BufferedStatus",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Status/Search"
            }
        }
    }
});